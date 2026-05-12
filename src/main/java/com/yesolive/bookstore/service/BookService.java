package com.yesolive.bookstore.service;


import com.yesolive.bookstore.model.dao.BookDao;
import com.yesolive.bookstore.model.dto.Book;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BookService {

    private final BookDao bookDao;

    public BookService(BookDao bookDao) {
        this.bookDao = bookDao;
    }

    /**
     * 도서 등록
     */
    public int insert(Book book) {
        return bookDao.insert(book);
    }

    /**
     * 전체 도서 조회
     */
    public List<Book> selectAll() {
        return bookDao.selectAll();
    }

    /**
     * ISBN으로 도서 조회
     */
    public Book select(String isbn) {
        return bookDao.select(isbn);
    }

    /**
     * 도서 정보 수정
     */
    public int update(Book book) {
        return bookDao.update(book);
    }

    /**
     * 도서 삭제
     */
    public int delete(String isbn) {
        // TODO: BookDao를 통해 도서를 삭제
        return bookDao.delete(isbn);
    }
}
