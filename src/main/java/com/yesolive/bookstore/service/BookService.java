package com.yesolive.bookstore.service;

import com.yesolive.bookstore.model.dto.BookCardDto;
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

    public Page<BookCardDto> findBookCards(Pageable pageable) {
        return bookRepository.findBookCards(pageable);
    }

    public BookCardDto findBookCardByIsbn(String isbn) {
        return bookRepository.findBookCardByIsbn(isbn)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 도서입니다. isbn=" + isbn));
    }
}
