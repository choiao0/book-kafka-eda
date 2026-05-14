package com.yesolive.bookstore.batch.job;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.listener.JobExecutionListener;
import org.springframework.batch.core.job.JobExecution;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Configuration
public class DisplayInfoBatchJob {

    private static final Logger log = LoggerFactory.getLogger(DisplayInfoBatchJob.class);

    /** 현재 유효한 프로모션이 하나라도 있는 책만 UPSERT */
    private static final String UPSERT_SQL = """
            INSERT INTO book_display_info (
                book_id, has_bestseller_tag, bestseller_rank,
                has_discount_tag, discount_rate, display_price,
                has_gift_tag, gift_status, gift_remaining_qty,
                data_source, last_synced_at, created_at, updated_at
            )
            SELECT
                b.book_id,
                CASE WHEN bp.promotion_id IS NOT NULL THEN 1 ELSE 0 END,
                bp.ranking,
                CASE WHEN dp.promotion_id IS NOT NULL THEN 1 ELSE 0 END,
                dp.discount_rate,
                dp.discounted_price,
                CASE WHEN gp.promotion_id IS NOT NULL THEN 1 ELSE 0 END,
                gp.status,
                gp.remaining_quantity,
                'BATCH',
                NOW(), NOW(), NOW()
            FROM book b
            LEFT JOIN bestseller_promotion bp
                ON b.book_id = bp.book_id AND NOW() BETWEEN bp.valid_from AND bp.valid_until
            LEFT JOIN discount_promotion dp
                ON b.book_id = dp.book_id AND NOW() BETWEEN dp.valid_from AND dp.valid_until
            LEFT JOIN gift_promotion gp
                ON b.book_id = gp.book_id AND NOW() BETWEEN gp.valid_from AND gp.valid_until
            WHERE bp.promotion_id IS NOT NULL
               OR dp.promotion_id IS NOT NULL
               OR gp.promotion_id IS NOT NULL
            ON DUPLICATE KEY UPDATE
                has_bestseller_tag = VALUES(has_bestseller_tag),
                bestseller_rank    = VALUES(bestseller_rank),
                has_discount_tag   = VALUES(has_discount_tag),
                discount_rate      = VALUES(discount_rate),
                display_price      = VALUES(display_price),
                has_gift_tag       = VALUES(has_gift_tag),
                gift_status        = VALUES(gift_status),
                gift_remaining_qty = VALUES(gift_remaining_qty),
                data_source        = VALUES(data_source),
                last_synced_at     = VALUES(last_synced_at),
                updated_at         = VALUES(updated_at)
            """;

    /** 모든 프로모션이 만료된 책 행 삭제 */
    private static final String DELETE_EXPIRED_SQL = """
            DELETE FROM book_display_info
            WHERE NOT EXISTS (
                SELECT 1 FROM bestseller_promotion bp
                WHERE bp.book_id = book_display_info.book_id
                  AND NOW() BETWEEN bp.valid_from AND bp.valid_until
            )
            AND NOT EXISTS (
                SELECT 1 FROM discount_promotion dp
                WHERE dp.book_id = book_display_info.book_id
                  AND NOW() BETWEEN dp.valid_from AND dp.valid_until
            )
            AND NOT EXISTS (
                SELECT 1 FROM gift_promotion gp
                WHERE gp.book_id = book_display_info.book_id
                  AND NOW() BETWEEN gp.valid_from AND gp.valid_until
            )
            """;

    private static final String UPSERT_COUNT_KEY = "upsertCount";
    private static final String DELETE_COUNT_KEY  = "deleteCount";

    private final JdbcTemplate jdbcTemplate;

    public DisplayInfoBatchJob(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    @Bean
    public Job displayInfoSyncJob(JobRepository jobRepository,
                                  Step displayInfoSyncStep,
                                  JobExecutionListener batchJobLogListener) {
        return new JobBuilder("displayInfoSyncJob", jobRepository)
                .listener(batchJobLogListener)
                .start(displayInfoSyncStep)
                .build();
    }

    @Bean
    public Step displayInfoSyncStep(JobRepository jobRepository,
                                    PlatformTransactionManager transactionManager) {
        return new StepBuilder("displayInfoSyncStep", jobRepository)
                .tasklet(refreshTasklet(), transactionManager)
                .build();
    }

    @Bean
    public Tasklet refreshTasklet() {
        return (StepContribution contribution, ChunkContext chunkContext) -> {

            long start = System.currentTimeMillis();

            LocalDateTime batchStarted = LocalDateTime.now();
            String batchStartedTime = batchStarted.format(
                    DateTimeFormatter.ofPattern("HH:mm:ss")
            );

            int upserted = jdbcTemplate.update(UPSERT_SQL);
            int deleted = jdbcTemplate.update(DELETE_EXPIRED_SQL);

            long elapsed = System.currentTimeMillis() - start;

            var ctx = chunkContext.getStepContext()
                    .getStepExecution()
                    .getJobExecution()
                    .getExecutionContext();

            ctx.putInt(UPSERT_COUNT_KEY, upserted);
            ctx.putInt(DELETE_COUNT_KEY, deleted);

            log.info(
                    "[BATCH] 갱신 완료 | 실행 시각: {} | 소요시간: {}ms | UPSERT: {}행 | DELETE: {}행",
                    batchStartedTime,
                    elapsed,
                    upserted,
                    deleted
            );

            return RepeatStatus.FINISHED;
        };
    }

    @Bean
    public JobExecutionListener batchJobLogListener() {
        return new JobExecutionListener() {
            @Override
            public void afterJob(JobExecution jobExecution) {
                boolean failed = jobExecution.getStatus().isUnsuccessful();
                String status = failed ? "FAILED" : "COMPLETED";

                int processedCount = 0;
                String errorMsg = null;

                if (!failed) {
                    var ctx = jobExecution.getExecutionContext();
                    processedCount = ctx.getInt(UPSERT_COUNT_KEY, 0)
                                   + ctx.getInt(DELETE_COUNT_KEY, 0);
                } else {
                    errorMsg = jobExecution.getAllFailureExceptions().stream()
                            .map(Throwable::getMessage)
                            .filter(m -> m != null && !m.isBlank())
                            .findFirst()
                            .orElse("알 수 없는 오류");
                }

                jdbcTemplate.update("""
                        INSERT INTO batch_job_log
                          (job_name, status, processed_count, failed_count, started_at, finished_at, error_message)
                        VALUES (?, ?, ?, 0, ?, ?, ?)
                        """,
                        "displayInfoSyncJob",
                        status,
                        processedCount,
                        jobExecution.getStartTime(),
                        LocalDateTime.now(),
                        errorMsg);
            }
        };
    }
}
