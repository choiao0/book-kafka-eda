package com.yesolive.bookstore.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "book_display_info")
public class BookDisplayInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "display_id")
    private Long displayId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id", nullable = false, unique = true)
    private Book book;

    @Column(name = "has_bestseller_tag", nullable = false)
    private Boolean hasBestsellerTag = false;

    @Column(name = "bestseller_rank")
    private Integer bestsellerRank;

    @Column(name = "has_discount_tag", nullable = false)
    private Boolean hasDiscountTag = false;

    @Column(name = "discount_rate")
    private Integer discountRate;

    @Column(name = "display_price")
    private Integer displayPrice;

    @Column(name = "has_gift_tag", nullable = false)
    private Boolean hasGiftTag = false;

    @Column(name = "gift_status", length = 20)
    private String giftStatus;

    @Column(name = "gift_remaining_qty")
    private Integer giftRemainingQty;

    @Column(name = "data_source", length = 20)
    private String dataSource;

    @Column(name = "last_synced_at")
    private LocalDateTime lastSyncedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    protected BookDisplayInfo() {}

    public Long getDisplayId() { return displayId; }
    public Book getBook() { return book; }
    public Boolean getHasBestsellerTag() { return hasBestsellerTag; }
    public Integer getBestsellerRank() { return bestsellerRank; }
    public Boolean getHasDiscountTag() { return hasDiscountTag; }
    public Integer getDiscountRate() { return discountRate; }
    public Integer getDisplayPrice() { return displayPrice; }
    public Boolean getHasGiftTag() { return hasGiftTag; }
    public String getGiftStatus() { return giftStatus; }
    public Integer getGiftRemainingQty() { return giftRemainingQty; }
}
