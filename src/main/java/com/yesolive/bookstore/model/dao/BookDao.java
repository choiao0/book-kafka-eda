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

}
