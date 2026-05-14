package com.yesolive.bookstore.kafka.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.yesolive.bookstore.kafka.event.GiftPromotionEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class GiftPromotionConsumer {

    private static final Logger log = LoggerFactory.getLogger(GiftPromotionConsumer.class);

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final JdbcTemplate jdbcTemplate;

    public GiftPromotionConsumer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @KafkaListener(topics = "${kafka.topic.gift-promotion}", groupId = "bookstore-group")
    public void consume(String message) {
        GiftPromotionEvent event;
        try {
            event = MAPPER.readValue(message, GiftPromotionEvent.class);
        } catch (Exception e) {
            log.error("[KAFKA] 역직렬화 실패 | message: {}", message, e);
            return;
        }

        log.info("[KAFKA] 수신 | eventId: {} | bookId: {} | type: {}",
                event.eventId(), event.bookId(), event.eventType());

        // book_display_info 즉시 갱신 — 행이 없으면 INSERT, 있으면 gift 컬럼만 UPDATE
        jdbcTemplate.update("""
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

        log.info("[KAFKA] book_display_info 갱신 완료 | bookId: {} | giftStatus: {}",
                event.bookId(), event.giftStatus());

        // 이벤트 로그 CONSUMED 처리
        jdbcTemplate.update("""
                UPDATE kafka_event_log
                SET status = 'CONSUMED', consumed_at = NOW()
                WHERE event_id = ?
                """, event.eventId());
    }
}
