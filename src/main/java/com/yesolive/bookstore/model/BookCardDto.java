package com.yesolive.bookstore.model;

import lombok.Getter;

@Getter
public class BookCardDto {

    private Long bookId;
    private String isbn;
    private String title;
    private String author;
    private String publisher;
    private Integer regularPrice;
    private String thumbnailUrl;

    private Boolean hasBestsellerTag;
    private Integer bestsellerRank;
    private Boolean hasDiscountTag;
    private Integer discountRate;
    private Integer displayPrice;
    private Boolean hasGiftTag;
    private String giftStatus;
    private Integer giftRemainingQty;


    public BookCardDto(Long bookId, String isbn, String title, String author, String publisher,
                       Integer regularPrice, String thumbnailUrl,
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
        this.hasBestsellerTag = hasBestsellerTag;
        this.bestsellerRank = bestsellerRank;
        this.hasDiscountTag = hasDiscountTag;
        this.discountRate = discountRate;
        this.displayPrice = displayPrice;
        this.hasGiftTag = hasGiftTag;
        this.giftStatus = giftStatus;
        this.giftRemainingQty = giftRemainingQty;
    }
}