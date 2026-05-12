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

}
