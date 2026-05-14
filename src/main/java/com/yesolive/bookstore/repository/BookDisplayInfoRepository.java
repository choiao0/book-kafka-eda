package com.yesolive.bookstore.repository;

import com.yesolive.bookstore.model.BookDisplayInfo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookDisplayInfoRepository extends JpaRepository<BookDisplayInfo, Long> {
}
