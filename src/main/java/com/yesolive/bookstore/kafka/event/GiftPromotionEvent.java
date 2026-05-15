package com.yesolive.bookstore.kafka.event;

public record GiftPromotionEvent(
        Long eventId,      // kafka_event_log PK — 소비 후 CONSUMED 처리에 사용
        Long bookId,
        String eventType,  // SOLD_OUT | RESTOCKED
        String giftStatus,
        int remainingQty
) {}
