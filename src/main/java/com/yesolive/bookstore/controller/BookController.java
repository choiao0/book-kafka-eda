package com.yesolive.bookstore.controller;

import com.yesolive.bookstore.model.Book;
import com.yesolive.bookstore.service.BookService;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/book")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping("/list")
    public String list(@RequestParam(defaultValue = "0") int page, Model model) {
        Pageable pageable = PageRequest.of(page, 16, Sort.by("bookId").ascending());
        Page<Book> bookPage = bookService.findAll(pageable);

        int currentPage = bookPage.getNumber();
        int totalPages = bookPage.getTotalPages();

        int blockSize = 10;
        int startPage = (currentPage / blockSize) * blockSize;
        int endPage = Math.min(startPage + blockSize - 1, totalPages - 1);

        model.addAttribute("books", bookPage.getContent());
        model.addAttribute("bookPage", bookPage);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);

        return "book/list";
    }

    @GetMapping("/{isbn}")
    public String detail(@PathVariable String isbn, Model model) {
        Book book = bookService.findByIsbn(isbn);
        model.addAttribute("book", book);
        System.out.println(model.getAttribute("book"));
        return "book/detail";
    }
}