package com.yesolive.bookstore.controller;

import com.yesolive.bookstore.service.BookService;
import com.yesolive.bookstore.model.dto.Book;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/book")
public class BookController {

    private final BookService bookService;

    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    /**
     * 도서 목록 조회
     */
    @GetMapping("/list")
    public String list(Model model) {
        List<Book> books = bookService.selectAll();
        model.addAttribute("books", books);
        return "book/list";
    }

    /**
     * 도서 등록 폼 표시
     */
    @GetMapping("/regist")
    public String showForm(Model model) {
        model.addAttribute("book", new Book());
        return "book/form";
    }

    /**
     * 도서 등록 처리
     */
    @PostMapping("/regist")
    public String createBook(@ModelAttribute Book book) {
        bookService.insert(book);
        return "redirect:/book/list";
    }

    /**
     * 도서 상세 조회
     */
    @GetMapping("/{isbn}")
    public String detail(@PathVariable String isbn, Model model) {
        Book book = bookService.select(isbn);
        model.addAttribute("book", book);
        return "book/detail";
    }

    /**
     * 도서 수정 폼 표시
     */
    @GetMapping("/{isbn}/edit")
    public String editForm(@PathVariable String isbn, Model model) {
        Book book = bookService.select(isbn);
        model.addAttribute("book", book);
        return "book/edit";
    }

    /**
     * 도서 수정 처리
     */
    @PostMapping("/{isbn}")
    public String update(@PathVariable String isbn, @ModelAttribute Book book) {
        bookService.update(book);
        return "redirect:/book/" + isbn;
    }

    // ============================================
    // [Step 1 미션] 삭제 처리 메서드를 구현하세요.
    // ============================================
    /**
     * 도서 삭제 처리
     * URL: POST /book/{isbn}/delete
     *
     * @param isbn 삭제할 도서의 ISBN
     * @return 삭제 후 목록 페이지로 리다이렉트
     */
    // TODO: @PostMapping 어노테이션을 사용하여 "/{isbn}/delete" 경로에 매핑하세요.
    // TODO: @PathVariable을 사용하여 isbn을 추출하세요.
    // TODO: bookService.delete(isbn)를 호출하세요.
    // TODO: "redirect:/book/list"를 반환하세요.

    // === 여기에 메서드 작성 ===
    @PostMapping("/{isbn}/delete")
    public String delete(@PathVariable String isbn) {
    	bookService.delete(isbn);
    	return "redirect:/book/list";
    }

}
