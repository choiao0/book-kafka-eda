package com.yesolive.bookstore.repository;

import com.yesolive.bookstore.model.Book;
import com.yesolive.bookstore.model.dto.BookCardDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface BookRepository extends JpaRepository<Book, Long> {

    @Query(value = """
        SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
            b.bookId, b.isbn, b.title, b.author, b.publisher, b.regularPrice, b.thumbnailUrl,
            b.content, b.publishedAt, b.createdAt,
            CASE WHEN d.hasBestsellerTag = true THEN true ELSE false END,
            d.bestsellerRank,
            CASE WHEN d.hasDiscountTag = true THEN true ELSE false END,
            d.discountRate, d.displayPrice,
            CASE WHEN d.hasGiftTag = true THEN true ELSE false END,
            d.giftStatus, d.giftRemainingQty
        )
        FROM Book b LEFT JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
    """,
    countQuery = "SELECT COUNT(b) FROM Book b")
    Page<BookCardDto> findBookCards(Pageable pageable);

    @Query("""
        SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
            b.bookId, b.isbn, b.title, b.author, b.publisher, b.regularPrice, b.thumbnailUrl,
            b.content, b.publishedAt, b.createdAt,
            CASE WHEN d.hasBestsellerTag = true THEN true ELSE false END,
            d.bestsellerRank,
            CASE WHEN d.hasDiscountTag = true THEN true ELSE false END,
            d.discountRate, d.displayPrice,
            CASE WHEN d.hasGiftTag = true THEN true ELSE false END,
            d.giftStatus, d.giftRemainingQty
        )
        FROM Book b LEFT JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
        WHERE b.isbn = :isbn
    """)
    Optional<BookCardDto> findBookCardByIsbn(@Param("isbn") String isbn);

    @Query("""
        SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
            b.bookId, b.isbn, b.title, b.author, b.publisher, b.regularPrice, b.thumbnailUrl,
            b.content, b.publishedAt, b.createdAt,
            true, d.bestsellerRank,
            CASE WHEN d.hasDiscountTag = true THEN true ELSE false END,
            d.discountRate, d.displayPrice,
            CASE WHEN d.hasGiftTag = true THEN true ELSE false END,
            d.giftStatus, d.giftRemainingQty
        )
        FROM Book b JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
        WHERE d.hasBestsellerTag = true
        ORDER BY d.bestsellerRank ASC
    """)
    List<BookCardDto> findBestsellers();

    @Query("""
        SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
            b.bookId, b.isbn, b.title, b.author, b.publisher, b.regularPrice, b.thumbnailUrl,
            b.content, b.publishedAt, b.createdAt,
            CASE WHEN d.hasBestsellerTag = true THEN true ELSE false END,
            d.bestsellerRank,
            true, d.discountRate, d.displayPrice,
            CASE WHEN d.hasGiftTag = true THEN true ELSE false END,
            d.giftStatus, d.giftRemainingQty
        )
        FROM Book b JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
        WHERE d.hasDiscountTag = true
        ORDER BY d.discountRate DESC
    """)
    List<BookCardDto> findDiscounted();

    @Query("""
        SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
            b.bookId, b.isbn, b.title, b.author, b.publisher, b.regularPrice, b.thumbnailUrl,
            b.content, b.publishedAt, b.createdAt,
            CASE WHEN d.hasBestsellerTag = true THEN true ELSE false END,
            d.bestsellerRank,
            CASE WHEN d.hasDiscountTag = true THEN true ELSE false END,
            d.discountRate, d.displayPrice,
            true, d.giftStatus, d.giftRemainingQty
        )
        FROM Book b JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
        WHERE d.hasGiftTag = true
        ORDER BY CASE d.giftStatus WHEN 'ACTIVE' THEN 0 ELSE 1 END, d.giftRemainingQty DESC
    """)
    List<BookCardDto> findGiftEvent();

    Optional<Book> findByIsbn(String isbn);
}
