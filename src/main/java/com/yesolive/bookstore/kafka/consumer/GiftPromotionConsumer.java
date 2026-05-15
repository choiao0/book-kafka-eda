package com.yesolive.bookstore.kafka.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.yesolive.bookstore.kafka.event.GiftPromotionEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Component
public class GiftPromotionConsumer {

    private static final Logger log = LoggerFactory.getLogger(GiftPromotionConsumer.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm:ss");

    private final JdbcTemplate jdbcTemplate;

    public GiftPromotionConsumer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @KafkaListener(topics = "${kafka.topic.gift-promotion}", groupId = "bookstore-group")
    public void consume(String message) {
        long consumeStart = System.currentTimeMillis();
        String consumeStartedTime = LocalDateTime.now().format(TIME_FMT);

        GiftPromotionEvent event;
        try {
            event = MAPPER.readValue(message, GiftPromotionEvent.class);
        } catch (Exception e) {
            log.error("[KAFKA] 역직렬화 실패 | message: {}", message, e);
            return;
        }

        log.info("[KAFKA] 수신 | eventId: {} | bookId: {} | type: {}",
                event.eventId(), event.bookId(), event.eventType());

        long beforeBufferReads = getStatusValue("Innodb_buffer_pool_read_requests");
        long beforeDiskReads   = getStatusValue("Innodb_buffer_pool_reads");
        long beforeRowsRead    = getReadRowsApprox();

        // book_display_info 즉시 갱신 — 행이 없으면 INSERT, 있으면 gift 컬럼만 UPDATE
        long dbStart = System.currentTimeMillis();
        int updated = jdbcTemplate.update("""
                INSERT INTO book_display_info
                    (book_id, has_gift_tag, gift_status, gift_remaining_qty, data_source, last_synced_at)
                VALUES (?, 1, ?, ?, 'EVENT', NOW())
                ON DUPLICATE KEY UPDATE
                    has_gift_tag       = 1,
                    gift_status        = VALUES(gift_status),
                    gift_remaining_qty = VALUES(gift_remaining_qty),
                    data_source        = 'EVENT',
                    last_synced_at     = NOW()
                """, event.bookId(), event.giftStatus(), event.remainingQty());
        long dbElapsed = System.currentTimeMillis() - dbStart;

        long afterBufferReads = getStatusValue("Innodb_buffer_pool_read_requests");
        long afterDiskReads   = getStatusValue("Innodb_buffer_pool_reads");
        long afterRowsRead    = getReadRowsApprox();

        long bufferReadDiff   = afterBufferReads - beforeBufferReads;
        long diskReadDiff     = afterDiskReads   - beforeDiskReads;
        long rowsReadApproxDiff = afterRowsRead  - beforeRowsRead;

        // published_at 기준 E2E 지연 측정
        Long e2eMs = jdbcTemplate.queryForObject("""
                SELECT TIMESTAMPDIFF(MICROSECOND, published_at, NOW()) / 1000
                FROM kafka_event_log
                WHERE event_id = ?
                """, Long.class, event.eventId());

        // 이벤트 로그 CONSUMED 처리
        jdbcTemplate.update("""
                UPDATE kafka_event_log
                SET status = 'CONSUMED', consumed_at = NOW()
                WHERE event_id = ?
                """, event.eventId());

        long elapsed = System.currentTimeMillis() - consumeStart;

        log.info(
                "[KAFKA] 처리 완료 | 수신 시각: {} | 총 소요시간: {}ms | DB갱신: {}행({}ms) | E2E지연: {}ms | buffer_reads: {} | disk_reads: {} | rows_read_approx: {}",
                consumeStartedTime,
                elapsed,
                updated,
                dbElapsed,
                e2eMs,
                bufferReadDiff,
                diskReadDiff,
                rowsReadApproxDiff
        );
    }

    private long getStatusValue(String name) {
        return jdbcTemplate.queryForObject(
                "SHOW GLOBAL STATUS LIKE ?",
                (rs, rowNum) -> rs.getLong("Value"),
                name
        );
    }

    private long getReadRowsApprox() {
        return getStatusValue("Handler_read_first")
             + getStatusValue("Handler_read_key")
             + getStatusValue("Handler_read_next")
             + getStatusValue("Handler_read_prev")
             + getStatusValue("Handler_read_rnd")
             + getStatusValue("Handler_read_rnd_next");
    }
}
