package com.yesolive.bookstore.service;

import com.yesolive.bookstore.model.Book;
import com.yesolive.bookstore.repository.BookRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class BookService {

    private final BookRepository bookRepository;

    public BookService(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    public Page<Book> findAll(Pageable pageable) {
        return bookRepository.findAll(pageable);
    }

    public Book findByIsbn(String isbn) {
        return bookRepository.findByIsbn(isbn)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 도서입니다. isbn=" + isbn));
    }
}