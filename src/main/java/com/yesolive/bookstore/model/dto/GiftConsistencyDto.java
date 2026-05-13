package com.yesolive.bookstore.model.dto;

public record GiftConsistencyDto(
        Long bookId,
        String title,

        // book_display_info 기준 (배치 캐시)
        Boolean cachedHasGiftTag,
        String cachedGiftStatus,
        Integer cachedGiftRemainingQty,

        // gift_promotion 테이블 직접 조회 (실제 데이터)
        String realGiftStatus,
        Integer realGiftRemainingQty
) {}
