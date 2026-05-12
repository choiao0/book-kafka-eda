package com.yesolive.bookstore.model.dao;

import com.yesolive.bookstore.model.dto.Book;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class BookDao {

    private final Map<String, Book> bookStore = new HashMap<>();

    public BookDao() {
        insert(new Book("978-89-01", "Java 프로그래밍", "김싸피", 30000));
        insert(new Book("978-89-02", "스프링 기초", "박싸피", 25000));
        insert(new Book("978-89-03", "좋은 코드", "제임스 싸피", 33000));
    }

    /**
     * 도서 등록
     */
    public int insert(Book book) {
        if (bookStore.containsKey(book.getIsbn())) {
            return 0;
        }
        bookStore.put(book.getIsbn(), book);
        return 1;
    }

    /**
     * 전체 도서 조회
     */
    public List<Book> selectAll() {
        return new ArrayList<>(bookStore.values());
    }

    /**
     * ISBN으로 도서 조회
     */
    public Book select(String isbn) {
        return bookStore.get(isbn);
    }

    /**
     * 도서 정보 수정
     */
    public int update(Book book) {
        Book existingBook = bookStore.get(book.getIsbn());
        if (existingBook != null) {
            existingBook.setTitle(book.getTitle());
            existingBook.setAuthor(book.getAuthor());
            existingBook.setPrice(book.getPrice());
            return 1;
        }
        return 0;
    }

    // ============================================
    // [Step 2 미션] 삭제 메서드를 구현하세요.
    // ============================================
    /**
     * 도서 삭제
     * @param isbn 삭제할 도서의 ISBN
     * @return 삭제 성공 시 1, 실패 시 0
     */
    public int delete(String isbn) {
        // TODO: bookStore에서 해당 ISBN의 도서를 삭제하세요.
        // TODO: 삭제 성공 시 1, 실패 시 0을 반환하세요.

        // === 여기에 코드 작성 ===
    	bookStore.remove(isbn);
    	if (bookStore.containsKey(isbn)) return 1;

        return 0; // 이 줄을 수정하세요.
    }
}
