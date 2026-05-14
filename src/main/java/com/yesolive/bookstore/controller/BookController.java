package com.yesolive.bookstore.controller;

import com.yesolive.bookstore.model.dto.BookCardDto;
import com.yesolive.bookstore.model.dto.GiftConsistencyDto;
import com.yesolive.bookstore.service.BookService;
import org.springframework.data.domain.*;
import org.springframework.http.MediaType;
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
    public String list(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "all") String tab,
                       Model model) {
        Pageable pageable = PageRequest.of(page, 16, Sort.by("bookId").ascending());
        Page<BookCardDto> bookPage = bookService.findBookCards(pageable);

        int currentPage = bookPage.getNumber();
        int blockSize = 10;
        int startPage = (currentPage / blockSize) * blockSize;
        int endPage = Math.min(startPage + blockSize - 1, bookPage.getTotalPages() - 1);

        model.addAttribute("books", bookPage.getContent());
        model.addAttribute("bookPage", bookPage);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);

        model.addAttribute("bestsellers", bookService.findBestsellers());
        model.addAttribute("discounted",  bookService.findDiscounted());
        model.addAttribute("giftEvent",   bookService.findGiftEvent());

        model.addAttribute("activeTab", tab);

        return "book/list";
    }

    @GetMapping("/promotion")
    public String promotion() {
        return "redirect:/book/list?tab=bestseller";
    }

    @GetMapping("/{isbn}")
    public String detail(@PathVariable String isbn, Model model) {
        BookCardDto book = bookService.findBookDetailByIsbn(isbn);
        model.addAttribute("book", book);
        return "book/detail";
    }

    // ── REST API (정합성 확인용) ─────────────────────────────────────────────

    /** 전체 도서 목록 API — book_display_info 기준 (배치 캐시) */
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public java.util.List<BookCardDto> listApi() {
        return bookService.findAllBookCards();
    }

    /** 도서 상세 API — gift_promotion 실제 테이블 직접 조회로 정합성 갭 확인 */
    @GetMapping(value = "/{bookId}", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public GiftConsistencyDto detailApi(@PathVariable Long bookId) {
        return bookService.findGiftConsistencyByBookId(bookId);
    }
}
