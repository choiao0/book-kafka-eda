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
