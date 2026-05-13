<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>도서 상세</title>
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
            max-width: 1000px;
            margin: 0 auto;
            padding: 50px 24px;
        }

        .detail-card {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 40px;
            background-color: white;
            border-radius: 24px;
            padding: 36px;
            box-shadow: 0 8px 28px rgba(0,0,0,0.08);
        }

        .thumb {
            width: 100%;
            height: 460px;
            border-radius: 18px;
            background-color: #f1f3f5;
            overflow: hidden;
        }

        .thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .badge {
            display: inline-block;
            padding: 7px 12px;
            border-radius: 999px;
            background-color: #eaf7d1;
            color: #4c7f00;
            font-size: 13px;
            font-weight: 800;
            margin-bottom: 16px;
        }

        h1 {
            margin: 0 0 12px;
            font-size: 30px;
            line-height: 1.35;
        }

        .author {
            color: #777;
            font-size: 15px;
            margin-bottom: 24px;
        }

        .price {
            font-size: 28px;
            font-weight: 900;
            color: #222;
            margin-bottom: 28px;
        }

        .info-list {
            border-top: 1px solid #eee;
            border-bottom: 1px solid #eee;
            padding: 18px 0;
            margin-bottom: 28px;
        }

        .info-row {
            display: flex;
            margin: 12px 0;
            font-size: 15px;
        }

        .label {
            width: 90px;
            color: #999;
            font-weight: 700;
        }

        .value {
            flex: 1;
            color: #333;
        }

        .content {
            line-height: 1.7;
            color: #444;
            margin-bottom: 30px;
        }

        .button-group {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .btn {
            display: inline-block;
            padding: 12px 20px;
            border-radius: 999px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            font-weight: 800;
        }

        .btn-edit {
            background-color: #9acd32;
            color: #111;
        }

        .btn-delete {
            background-color: #ff4d4f;
            color: white;
        }

        .btn-back {
            background-color: #f1f3f5;
            color: #333;
        }

        .btn:hover {
            opacity: 0.85;
        }

        .promo-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 20px;
        }

        .promo-tag {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 800;
        }

        .tag-bestseller {
            background-color: #fff8dc;
            color: #7a5800;
            border: 1.5px solid #ffd700;
        }

        .tag-discount {
            background-color: #fff1f0;
            color: #cf1322;
            border: 1.5px solid #ff4d4f;
        }

        .tag-gift {
            background-color: #f6ffed;
            color: #237804;
            border: 1.5px solid #52c41a;
        }

        .tag-gift.sold-out {
            background-color: #f5f5f5;
            color: #888;
            border: 1.5px solid #ccc;
        }

        .price-row {
            display: flex;
            align-items: baseline;
            gap: 8px;
            flex-wrap: wrap;
        }

        .discount-rate {
            font-size: 26px;
            font-weight: 900;
            color: #e02020;
        }

        .sale-price {
            font-size: 26px;
            font-weight: 900;
            color: #222;
        }

        .original-price {
            font-size: 16px;
            color: #aaa;
            text-decoration: line-through;
        }
    </style>
</head>
<body>
<div class="container">

    <div class="detail-card">
        <div class="thumb">
            <img src="${book.thumbnailUrl}" alt="${book.title}">
        </div>

        <div>
            <div class="badge">YESOLIVE BOOK</div>

            <h1>${book.title}</h1>

            <div class="author">
                ${book.author} · ${book.publisher}
            </div>

            <div class="promo-tags">
                <c:if test="${book.hasBestsellerTag}">
                    <span class="promo-tag tag-bestseller">&#11088; 베스트셀러 ${book.bestsellerRank}위</span>
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
                            <span class="promo-tag tag-gift">&#127381; 선착순 증정 (${book.giftRemainingQty}개 남음)</span>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>

            <div class="price">
                <c:choose>
                    <c:when test="${book.hasDiscountTag and book.displayPrice != null}">
                        <div class="price-row">
                            <span class="discount-rate">${book.discountRate}%</span>
                            <span class="sale-price">${book.displayPrice}원</span>
                            <span class="original-price">${book.regularPrice}원</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        ${book.regularPrice}원
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="info-list">
                <div class="info-row">
                    <!-- <div class="label">ISBN</div> -->
                    <!-- <div class="value">${book.isbn}</div> -->
                </div>

                <div class="info-row">
                    <div class="label">출판일</div>
                    <div class="value">${book.publishedAt}</div>
                </div>

                <div class="info-row">
                    <div class="label">등록일</div>
                    <div class="value">${book.createdAt}</div>
                </div>
            </div>

            <div class="content">
                ${book.content}
            </div>


            <div class="button-group">
                <!--
                <a href="${pageContext.request.contextPath}/book/${book.isbn}/edit"
                   class="btn btn-edit">수정</a>

                <form action="${pageContext.request.contextPath}/book/${book.isbn}/delete"
                      method="post"
                      style="display:inline;"
                      onsubmit="return confirm('정말 삭제하시겠습니까?');">
                    <button type="submit" class="btn btn-delete">삭제</button>
                </form>
                -->

                <a href="${pageContext.request.contextPath}/book/list"
                   class="btn btn-back">목록으로</a>
            </div>

        </div>
    </div>

</div>
</body>
</html>