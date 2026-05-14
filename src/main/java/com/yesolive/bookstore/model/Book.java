package com.yesolive.bookstore.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "book")
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "book_id")
    private Long bookId;

    @Column(name = "isbn", nullable = false, unique = true, length = 20)
    private String isbn;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "content", length = 2000)
    private String content;

    @Column(name = "author", nullable = false, length = 100)
    private String author;

    @Column(name = "publisher", length = 100)
    private String publisher;

    @Column(name = "regular_price", nullable = false)
    private Integer regularPrice;

    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    protected Book() {}

    public Book(String isbn, String title, String author, String publisher,
                Integer regularPrice, String content, String thumbnailUrl,
                LocalDateTime publishedAt) {
        this.isbn = isbn;
        this.title = title;
        this.content = content;
        this.author = author;
        this.publisher = publisher;
        this.regularPrice = regularPrice;
        this.thumbnailUrl = thumbnailUrl;
        this.publishedAt = publishedAt;
    }

    public Long getBookId() { return bookId; }
    public String getIsbn() { return isbn; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public String getAuthor() { return author; }
    public String getPublisher() { return publisher; }
    public Integer getRegularPrice() { return regularPrice; }
    public String getThumbnailUrl() { return thumbnailUrl; }
    public LocalDateTime getPublishedAt() { return publishedAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}