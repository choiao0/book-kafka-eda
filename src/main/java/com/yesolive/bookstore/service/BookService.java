package com.yesolive.bookstore.service;

import com.yesolive.bookstore.model.dto.BookCardDto;
import com.yesolive.bookstore.model.dto.GiftConsistencyDto;
import com.yesolive.bookstore.repository.BookRepository;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class BookService {

    private final BookRepository bookRepository;
    private final JdbcTemplate jdbcTemplate;

    public BookService(BookRepository bookRepository, JdbcTemplate jdbcTemplate) {
        this.bookRepository = bookRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    public Page<BookCardDto> findBookCards(Pageable pageable) {
        return bookRepository.findBookCards(pageable);
    }

    public List<BookCardDto> findAllBookCards() {
        return bookRepository.findAllBookCards();
    }

    public BookCardDto findBookCardByIsbn(String isbn) {
        return bookRepository.findBookCardByIsbn(isbn)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 도서입니다. isbn=" + isbn));
    }

    public List<BookCardDto> findBestsellers() { return bookRepository.findBestsellers(); }
    public List<BookCardDto> findDiscounted()   { return bookRepository.findDiscounted(); }
    public List<BookCardDto> findGiftEvent()    { return bookRepository.findGiftEvent(); }

    /** promotion 테이블을 직접 조회해 상세 페이지용 BookCardDto를 반환한다. */
    public BookCardDto findBookDetailByIsbn(String isbn) {
        return jdbcTemplate.query("""
                SELECT
                    b.book_id, b.isbn, b.title, b.author, b.publisher,
                    b.regular_price, b.thumbnail_url, b.content,
                    b.published_at, b.created_at,
                    (SELECT bp.ranking
                     FROM bestseller_promotion bp
                     WHERE bp.book_id = b.book_id
                       AND NOW() BETWEEN bp.valid_from AND bp.valid_until
                     LIMIT 1) AS bestseller_rank,
                    (SELECT dp.discount_rate
                     FROM discount_promotion dp
                     WHERE dp.book_id = b.book_id
                       AND NOW() BETWEEN dp.valid_from AND dp.valid_until
                     LIMIT 1) AS discount_rate,
                    (SELECT dp.discounted_price
                     FROM discount_promotion dp
                     WHERE dp.book_id = b.book_id
                       AND NOW() BETWEEN dp.valid_from AND dp.valid_until
                     LIMIT 1) AS discounted_price,
                    (SELECT gp.status
                     FROM gift_promotion gp
                     WHERE gp.book_id = b.book_id
                       AND NOW() BETWEEN gp.valid_from AND gp.valid_until
                     LIMIT 1) AS gift_status,
                    (SELECT gp.remaining_quantity
                     FROM gift_promotion gp
                     WHERE gp.book_id = b.book_id
                       AND NOW() BETWEEN gp.valid_from AND gp.valid_until
                     LIMIT 1) AS gift_remaining_qty
                FROM book b
                WHERE b.isbn = ?
                """,
                (rs, rowNum) -> {
                    Integer bestsellerRank  = (Integer) rs.getObject("bestseller_rank");
                    Integer discountRate    = (Integer) rs.getObject("discount_rate");
                    Integer discountedPrice = (Integer) rs.getObject("discounted_price");
                    String  giftStatus      = rs.getString("gift_status");
                    Integer giftRemainingQty = (Integer) rs.getObject("gift_remaining_qty");
                    return new BookCardDto(
                            rs.getLong("book_id"),
                            rs.getString("isbn"),
                            rs.getString("title"),
                            rs.getString("author"),
                            rs.getString("publisher"),
                            rs.getInt("regular_price"),
                            rs.getString("thumbnail_url"),
                            rs.getString("content"),
                            rs.getTimestamp("published_at") != null
                                    ? rs.getTimestamp("published_at").toLocalDateTime() : null,
                            rs.getTimestamp("created_at").toLocalDateTime(),
                            bestsellerRank  != null,
                            bestsellerRank,
                            discountRate    != null,
                            discountRate,
                            discountedPrice,
                            giftStatus      != null,
                            giftStatus,
                            giftRemainingQty
                    );
                },
                isbn
        ).stream().findFirst()
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 도서입니다. isbn=" + isbn));
    }

    /** gift_promotion과 book_display_info를 동시에 조회해 정합성 갭을 확인한다. */
    public GiftConsistencyDto findGiftConsistencyByBookId(Long bookId) {
        // book_display_info (배치 캐시)
        Map<String, Object> cached = jdbcTemplate.queryForMap("""
                SELECT b.book_id, b.title,
                       d.has_gift_tag, d.gift_status, d.gift_remaining_qty
                FROM book b
                LEFT JOIN book_display_info d ON b.book_id = d.book_id
                WHERE b.book_id = ?
                """, bookId);

        // gift_promotion 실제 테이블 직접 조회
        String realStatus = null;
        Integer realRemaining = null;
        try {
            Map<String, Object> real = jdbcTemplate.queryForMap("""
                    SELECT status, remaining_quantity
                    FROM gift_promotion
                    WHERE book_id = ? AND NOW() BETWEEN valid_from AND valid_until
                    LIMIT 1
                    """, bookId);
            realStatus    = (String) real.get("status");
            realRemaining = ((Number) real.get("remaining_quantity")).intValue();
        } catch (EmptyResultDataAccessException ignored) {}

        Number hasGiftTagNum = (Number) cached.get("has_gift_tag");
        return new GiftConsistencyDto(
                ((Number) cached.get("book_id")).longValue(),
                (String) cached.get("title"),
                hasGiftTagNum != null && hasGiftTagNum.intValue() == 1,
                (String)  cached.get("gift_status"),
                cached.get("gift_remaining_qty") != null
                        ? ((Number) cached.get("gift_remaining_qty")).intValue() : null,
                realStatus,
                realRemaining
        );
    }
}
