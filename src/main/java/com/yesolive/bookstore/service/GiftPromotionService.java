package com.yesolive.bookstore.service;

import com.yesolive.bookstore.kafka.producer.GiftPromotionProducer;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GiftPromotionService {

    private final JdbcTemplate jdbcTemplate;
    private final GiftPromotionProducer producer;

    public GiftPromotionService(JdbcTemplate jdbcTemplate, GiftPromotionProducer producer) {
        this.jdbcTemplate = jdbcTemplate;
        this.producer = producer;
    }

    @Transactional
    public void soldOut(Long bookId) {
        int updated = jdbcTemplate.update("""
                UPDATE gift_promotion
                SET remaining_quantity = 0, status = 'SOLD_OUT'
                WHERE book_id = ?
                  AND NOW() BETWEEN valid_from AND valid_until
                """, bookId);

        if (updated == 0) {
            throw new IllegalArgumentException("활성 선착순 프로모션이 없습니다. bookId=" + bookId);
        }

        producer.publish(bookId, "SOLD_OUT", "SOLD_OUT", 0);
    }

    @Transactional
    public void restock(Long bookId, int qty) {
        if (qty <= 0) {
            throw new IllegalArgumentException("재입고 수량은 1 이상이어야 합니다.");
        }

        int updated = jdbcTemplate.update("""
                UPDATE gift_promotion
                SET remaining_quantity = ?, status = 'ACTIVE'
                WHERE book_id = ?
                  AND NOW() BETWEEN valid_from AND valid_until
                """, qty, bookId);

        if (updated == 0) {
            throw new IllegalArgumentException("활성 선착순 프로모션이 없습니다. bookId=" + bookId);
        }

        producer.publish(bookId, "RESTOCKED", "ACTIVE", qty);
    }
}
