package com.yesolive.bookstore.repository;

import com.yesolive.bookstore.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface BookRepository extends JpaRepository<Book, Long> {
    @Query("""
    SELECT new com.yesolive.bookstore.model.dto.BookCardDto(
        b.bookId,
        b.isbn,
        b.title,
        b.author,
        b.publisher,
        b.regularPrice,
        b.thumbnailUrl,
        CASE WHEN d.hasBestsellerTag = true THEN true ELSE false END,
        d.bestsellerRank,
        CASE WHEN d.hasDiscountTag = true THEN true ELSE false END,
        d.discountRate,
        d.displayPrice,
        CASE WHEN d.hasGiftTag = true THEN true ELSE false END,
        d.giftStatus,
        d.giftRemainingQty
    )
    FROM Book b
    LEFT JOIN BookDisplayInfo d ON b.bookId = d.book.bookId
""")
    Page<BookCardDto> findBookCards(Pageable pageable);

    Optional<Book> findByIsbn(String isbn);
}