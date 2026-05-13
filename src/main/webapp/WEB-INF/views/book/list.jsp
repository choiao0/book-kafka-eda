<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>도서 목록</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f8f9fa;
            color: #222;
        }

        .container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 40px 24px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
        }

        h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
        }

        .btn {
            display: inline-block;
            padding: 10px 18px;
            background-color: #9acd32;
            color: #111;
            text-decoration: none;
            border-radius: 999px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 700;
        }

        .btn:hover {
            background-color: #82b62a;
        }

        .book-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 28px 20px;
        }

        .book-card {
            background-color: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 14px rgba(0, 0, 0, 0.06);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
        }

        .book-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
        }

        .thumb-wrap {
            width: 100%;
            height: 250px;
            background-color: #f1f3f5;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
        }

        .thumb-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .book-info {
            padding: 16px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .book-title {
            display: block;
            font-size: 15px;
            font-weight: 800;
            line-height: 1.4;
            color: #222;
            text-decoration: none;
            min-height: 44px;
            margin-bottom: 6px;
        }

        .book-title:hover {
            text-decoration: underline;
        }

        .book-author {
            font-size: 13px;
            color: #777;
            margin-bottom: 10px;
        }

        .book-price {
            font-size: 18px;
            font-weight: 900;
            color: #e02020;
            margin-bottom: 8px;
        }

        .promo-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 12px;
            min-height: 0;
        }

        .promo-tag {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            line-height: 1.5;
            white-space: nowrap;
        }

        .tag-bestseller {
            background-color: #fff8e1;
            color: #b8860b;
            border: 1px solid #ffd700;
        }

        .tag-discount {
            background-color: #fff0f0;
            color: #c0392b;
            border: 1px solid #ffb3b3;
        }

        .tag-gift {
            background-color: #f0fff4;
            color: #276749;
            border: 1px solid #9ae6b4;
        }

        .tag-gift.sold-out {
            background-color: #f5f5f5;
            color: #999;
            border: 1px solid #ddd;
        }

        .card-actions {
            display: flex;
            gap: 8px;
            align-items: center;
            margin-top: auto;
        }

        .detail-link {
            flex: 1;
            text-align: center;
            padding: 8px 0;
            border-radius: 8px;
            background-color: #f1f3f5;
            color: #333;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
        }

        .detail-link:hover {
            background-color: #e9ecef;
        }

        .empty {
            padding: 80px 0;
            text-align: center;
            color: #777;
            background-color: white;
            border-radius: 16px;
        }

        .pagination {
            margin-top: 36px;
            text-align: center;
        }

        .page-btn {
            display: inline-block;
            min-width: 38px;
            padding: 10px 12px;
            margin: 0 3px;
            border-radius: 10px;
            background-color: white;
            color: #333;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .page-btn:hover {
            background-color: #f1f3f5;
        }

        .page-btn.active {
            background-color: #9acd32;
            color: #111;
        }
    </style>
</head>
<body>
<div class="container">

    <div class="header">
        <h1>도서 목록</h1>
        <!-- <a href="${pageContext.request.contextPath}/book/regist" class="btn">새 도서 등록</a> -->
    </div>

    <c:if test="${empty books}">
        <div class="empty">등록된 도서가 없습니다.</div>
    </c:if>

    <c:if test="${not empty books}">
        <div class="book-grid">
            <c:forEach var="book" items="${books}">
                <div class="book-card">
                    <a href="${pageContext.request.contextPath}/book/${book.isbn}">
                        <div class="thumb-wrap">
                            <img src="${book.thumbnailUrl}" alt="${book.title}">
                        </div>
                    </a>

                    <div class="book-info">
                        <a class="book-title" href="${pageContext.request.contextPath}/book/${book.isbn}">
                            ${book.title}
                        </a>

                        <div class="book-author">${book.author} · ${book.publisher}</div>

                        <div class="book-price">
                            <c:choose>
                                <c:when test="${book.hasDiscountTag and book.displayPrice != null}">
                                    ${book.displayPrice}원
                                    <span style="font-size:13px; font-weight:500; color:#aaa; text-decoration:line-through; margin-left:4px;">${book.regularPrice}원</span>
                                </c:when>
                                <c:otherwise>
                                    ${book.regularPrice}원
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="promo-tags">
                            <c:if test="${book.hasBestsellerTag}">
                                <span class="promo-tag tag-bestseller">⭐ 베스트셀러 ${book.bestsellerRank}위</span>
                            </c:if>
                            <c:if test="${book.hasDiscountTag}">
                                <span class="promo-tag tag-discount">${book.discountRate}% 할인</span>
                            </c:if>
                            <c:if test="${book.hasGiftTag}">
                                <c:choose>
                                    <c:when test="${book.giftStatus eq 'SOLD_OUT'}">
                                        <span class="promo-tag tag-gift sold-out">증정품 소진</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="promo-tag tag-gift">🎁 선착순 증정 (${book.giftRemainingQty}개 남음)</span>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div>

                        <div class="card-actions">
                            <a class="detail-link" href="${pageContext.request.contextPath}/book/${book.isbn}">
                                상세보기
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>

    <div class="pagination">
        <c:if test="${startPage > 0}">
            <a href="?page=${startPage - 10}" class="page-btn">이전</a>
        </c:if>

        <c:forEach begin="${startPage}" end="${endPage}" var="i">
            <a href="?page=${i}"
               class="page-btn ${bookPage.number == i ? 'active' : ''}">
                ${i + 1}
            </a>
        </c:forEach>

        <c:if test="${endPage < bookPage.totalPages - 1}">
            <a href="?page=${endPage + 1}" class="page-btn">다음</a>
        </c:if>
    </div>

</div>
</body>
</html>
