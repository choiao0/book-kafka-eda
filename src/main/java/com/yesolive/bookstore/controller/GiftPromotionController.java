package com.yesolive.bookstore.controller;

import com.yesolive.bookstore.service.GiftPromotionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/gift")
public class GiftPromotionController {

    private final GiftPromotionService giftPromotionService;

    public GiftPromotionController(GiftPromotionService giftPromotionService) {
        this.giftPromotionService = giftPromotionService;
    }

    /**
     * 선착순 증정품 소진 처리.
     * gift_promotion을 SOLD_OUT으로 변경하고 Kafka 이벤트를 발행한다.
     * 소비자가 이벤트를 처리하면 book_display_info가 배치 주기와 무관하게 즉시 갱신된다.
     */
    @PostMapping("/{bookId}/sold-out")
    public ResponseEntity<String> soldOut(@PathVariable Long bookId) {
        giftPromotionService.soldOut(bookId);
        return ResponseEntity.ok(
                "[bookId=%d] SOLD_OUT 처리 완료. Kafka 소비 후 book_display_info 즉시 반영".formatted(bookId));
    }

    /**
     * 선착순 증정품 재입고 처리.
     * gift_promotion을 ACTIVE로 복구하고 Kafka 이벤트를 발행한다.
     */
    @PostMapping("/{bookId}/restock")
    public ResponseEntity<String> restock(@PathVariable Long bookId,
                                          @RequestParam int qty) {
        giftPromotionService.restock(bookId, qty);
        return ResponseEntity.ok(
                "[bookId=%d] 재입고(%d개) 처리 완료. Kafka 소비 후 book_display_info 즉시 반영".formatted(bookId, qty));
    }
}
