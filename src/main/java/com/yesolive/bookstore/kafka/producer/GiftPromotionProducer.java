package com.yesolive.bookstore.kafka.producer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.yesolive.bookstore.kafka.event.GiftPromotionEvent;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.sql.Statement;
import java.util.Objects;

@Component
public class GiftPromotionProducer {

    private static final Logger log = LoggerFactory.getLogger(GiftPromotionProducer.class);

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final JdbcTemplate jdbcTemplate;

    @Value("${kafka.topic.gift-promotion}")
    private String topic;

    public GiftPromotionProducer(KafkaTemplate<String, String> kafkaTemplate,
                                 JdbcTemplate jdbcTemplate) {
        this.kafkaTemplate = kafkaTemplate;
        this.jdbcTemplate = jdbcTemplate;
    }

    public void publish(Long bookId, String eventType, String giftStatus, int remainingQty) {
        // kafka_event_log에 먼저 기록하고 PK(event_id)를 Kafka 메시지에 포함
        var keyHolder = new GeneratedKeyHolder();
        String payload = "{\"bookId\":%d,\"giftStatus\":\"%s\",\"remainingQty\":%d}"
                .formatted(bookId, giftStatus, remainingQty);

        jdbcTemplate.update(con -> {
            var ps = con.prepareStatement("""
                    INSERT INTO kafka_event_log
                      (topic, event_type, ref_id, payload, status, published_at)
                    VALUES (?, ?, ?, ?, 'PUBLISHED', NOW())
                    """, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, topic);
            ps.setString(2, eventType);
            ps.setLong(3, bookId);
            ps.setString(4, payload);
            return ps;
        }, keyHolder);

        Long eventId = Objects.requireNonNull(keyHolder.getKey()).longValue();
        GiftPromotionEvent event = new GiftPromotionEvent(eventId, bookId, eventType, giftStatus, remainingQty);

        try {
            String message = MAPPER.writeValueAsString(event);
            kafkaTemplate.send(topic, String.valueOf(bookId), message);
            log.info("[KAFKA] 발행 | topic: {} | eventId: {} | bookId: {} | type: {}",
                    topic, eventId, bookId, eventType);
        } catch (JsonProcessingException e) {
            log.error("[KAFKA] 직렬화 실패 | bookId: {}", bookId, e);
            throw new RuntimeException("Kafka 이벤트 직렬화 실패", e);
        }
    }
}
