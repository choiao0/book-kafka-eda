package com.yesolive.bookstore.batch.scheduler;

/*
 * ──────────────────────────────────────────────────────────────────────────
 * [시나리오] 정합성 깨짐 확인 절차
 *
 * 1. 배치 실행 직후 선착순 재고를 0으로 직접 변경 (gift_promotion 원본 수정)
 *    UPDATE gift_promotion SET remaining_quantity = 0, status = 'SOLD_OUT' WHERE book_id = 2;
 *    -- book_id 2 : 일기에도 거짓말을 쓰는 사람 (data.sql 기준)
 *
 * 2. 카드 목록(배치 캐시)과 실제 재고 비교
 *    SELECT
 *        b.title,
 *        bdi.gift_status        AS "카드에_보이는_상태(배치)",
 *        bdi.gift_remaining_qty AS "카드에_보이는_재고(배치)",
 *        gp.status              AS "실제_상태",
 *        gp.remaining_quantity  AS "실제_재고"
 *    FROM book b
 *    JOIN book_display_info bdi ON b.book_id = bdi.book_id
 *    JOIN gift_promotion gp ON b.book_id = gp.book_id
 *    WHERE b.book_id = 2;
 *
 * 3. REST API로 확인
 *    GET /book                  → book_display_info 기반 카드 목록 (배치 캐시)
 *    GET /book/{bookId}         → gift_promotion 실제 테이블 직접 조회값 비교
 *       예: curl -H "Accept: application/json" http://localhost:8080/book/2
 * ──────────────────────────────────────────────────────────────────────────
 */

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.job.parameters.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@ConditionalOnProperty(name = "batch.scheduler.enabled", havingValue = "true", matchIfMissing = false)
public class BatchScheduler {

    private static final Logger log = LoggerFactory.getLogger(BatchScheduler.class);

    private final JobLauncher jobLauncher;
    private final Job displayInfoSyncJob;

    public BatchScheduler(JobLauncher jobLauncher,
                          @Qualifier("displayInfoSyncJob") Job displayInfoSyncJob) {
        this.jobLauncher = jobLauncher;
        this.displayInfoSyncJob = displayInfoSyncJob;
    }

    @Scheduled(fixedDelay = 30_000) // 30초마다 실행
    @SuppressWarnings("deprecation")
    public void runDisplayInfoSync() {
        log.info("[BATCH] displayInfoSyncJob 스케줄 실행 시작");
        try {
            JobParameters params = new JobParametersBuilder()
                    .addLocalDateTime("runAt", LocalDateTime.now())
                    .toJobParameters();
            jobLauncher.run(displayInfoSyncJob, params);
        } catch (Exception e) {
            log.error("[BATCH] displayInfoSyncJob 실행 실패", e);
        }
    }
}
