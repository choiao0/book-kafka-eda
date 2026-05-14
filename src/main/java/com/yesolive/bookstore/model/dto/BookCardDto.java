package com.yesolive.bookstore.model.dto;

import java.time.LocalDateTime;

public class BookCardDto {

    private Long bookId;
    private String isbn;
    private String title;
    private String author;
    private String publisher;
    private Integer regularPrice;
    private String thumbnailUrl;
    private String content;
    private LocalDateTime publishedAt;
    private LocalDateTime createdAt;

    private Boolean hasBestsellerTag;
    private Integer bestsellerRank;
    private Boolean hasDiscountTag;
    private Integer discountRate;
    private Integer displayPrice;
    private Boolean hasGiftTag;
    private String giftStatus;
    private Integer giftRemainingQty;

    public BookCardDto(Long bookId, String isbn, String title, String author, String publisher,
                       Integer regularPrice, String thumbnailUrl, String content,
                       LocalDateTime publishedAt, LocalDateTime createdAt,
                       Boolean hasBestsellerTag, Integer bestsellerRank,
                       Boolean hasDiscountTag, Integer discountRate, Integer displayPrice,
                       Boolean hasGiftTag, String giftStatus, Integer giftRemainingQty) {
        this.bookId = bookId;
        this.isbn = isbn;
        this.title = title;
        this.author = author;
        this.publisher = publisher;
        this.regularPrice = regularPrice;
        this.thumbnailUrl = thumbnailUrl;
        this.content = content;
        this.publishedAt = publishedAt;
        this.createdAt = createdAt;
        this.hasBestsellerTag = hasBestsellerTag;
        this.bestsellerRank = bestsellerRank;
        this.hasDiscountTag = hasDiscountTag;
        this.discountRate = discountRate;
        this.displayPrice = displayPrice;
        this.hasGiftTag = hasGiftTag;
        this.giftStatus = giftStatus;
        this.giftRemainingQty = giftRemainingQty;
    }

    public Long getBookId() { return bookId; }
    public String getIsbn() { return isbn; }
    public String getTitle() { return title; }
    public String getAuthor() { return author; }
    public String getPublisher() { return publisher; }
    public Integer getRegularPrice() { return regularPrice; }
    public String getThumbnailUrl() { return thumbnailUrl; }
    public String getContent() { return content; }
    public LocalDateTime getPublishedAt() { return publishedAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public Boolean getHasBestsellerTag() { return hasBestsellerTag; }
    public Integer getBestsellerRank() { return bestsellerRank; }
    public Boolean getHasDiscountTag() { return hasDiscountTag; }
    public Integer getDiscountRate() { return discountRate; }
    public Integer getDisplayPrice() { return displayPrice; }
    public Boolean getHasGiftTag() { return hasGiftTag; }
    public String getGiftStatus() { return giftStatus; }
    public Integer getGiftRemainingQty() { return giftRemainingQty; }
}
