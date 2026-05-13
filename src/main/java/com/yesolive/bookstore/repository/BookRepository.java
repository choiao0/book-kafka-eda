package com.yesolive.bookstore.repository;

import com.yesolive.bookstore.model.Book;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class BookRepository {

    private final Map<String, Book> bookStore = new HashMap<>();

}
