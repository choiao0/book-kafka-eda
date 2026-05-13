<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>도서 목록</title>
    <style>
        * { box-sizing: border-box; }

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

        h1 { margin: 0 0 28px; font-size: 28px; font-weight: 800; }

        /* ── 탭 ── */
        .tabs {
            display: flex;
            gap: 0;
            border-bottom: 2px solid #e9ecef;
            margin-bottom: 32px;
        }

        .tab-btn {
            padding: 13px 24px;
            border: none;
            background: none;
            font-size: 15px;
            font-weight: 700;
            color: #999;
            cursor: pointer;
            position: relative;
            white-space: nowrap;
            text-decoration: none;
            display: inline-block;
        }

        .tab-btn:hover { color: #444; }

        .tab-btn.active { color: #222; }

        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            right: 0;
            height: 2px;
            background-color: #9acd32;
        }

        .tab-count {
            display: inline-block;
            margin-left: 5px;
            padding: 2px 7px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 800;
            background-color: #f1f3f5;
            color: #666;
        }

        .tab-btn.active .tab-count {
            background-color: #9acd32;
            color: #111;
        }

        /* ── 탭 패널 ── */
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        .section-desc {
            font-size: 14px;
            color: #888;
            margin-bottom: 24px;
        }

        /* ── 카드 그리드 ── */
        .book-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 28px 20px;
        }

        .book-card {
            background-color: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 14px rgba(0,0,0,0.06);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            display: flex;
            flex-direction: column;
        }

        .book-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        }

        .thumb-wrap {
            width: 100%;
            height: 230px;
            background-color: #f1f3f5;
            overflow: hidden;
            flex-shrink: 0;
            position: relative;
        }

        .thumb-wrap img { width: 100%; height: 100%; object-fit: cover; }

        /* 베스트셀러 순위 뱃지 */
        .rank-num {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background-color: #222;
            color: #fff;
            font-size: 13px;
            font-weight: 900;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .rank-num.top3 { background-color: #9acd32; color: #111; }

        /* ── 카드 정보 ── */
        .book-info {
            padding: 14px 16px 16px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        .book-title {
            font-size: 14px;
            font-weight: 800;
            line-height: 1.4;
            color: #222;
            text-decoration: none;
            margin-bottom: 5px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            min-height: 40px;
        }

        .book-title:hover { text-decoration: underline; }

        .book-author { font-size: 12px; color: #999; margin-bottom: 10px; }

        /* ── 가격 ── */
        .book-price { margin-bottom: 8px; }

        .price-row {
            display: flex;
            align-items: baseline;
            gap: 5px;
            flex-wrap: wrap;
        }

        .discount-rate { font-size: 17px; font-weight: 900; color: #e02020; }
        .sale-price    { font-size: 17px; font-weight: 900; color: #222; }
        .regular-price { font-size: 17px; font-weight: 900; color: #222; }
        .original-price { font-size: 12px; color: #aaa; text-decoration: line-through; }

        /* ── 프로모션 태그 ── */
        .promo-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
            margin-bottom: 12px;
        }

        .promo-tag {
            display: inline-flex;
            align-items: center;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            white-space: nowrap;
        }

        .tag-bestseller { background-color: #fff8e1; color: #b8860b; border: 1px solid #ffd700; }
        .tag-discount   { background-color: #fff0f0; color: #c0392b; border: 1px solid #ffb3b3; }
        .tag-gift       { background-color: #f0fff4; color: #276749; border: 1px solid #9ae6b4; }
        .tag-gift.sold-out { background-color: #f5f5f5; color: #999; border: 1px solid #ddd; }

        /* 탭별 하이라이트 정보 */
        .highlight-info {
            font-size: 12px;
            font-weight: 700;
            background-color: #f8f9fa;
            border-radius: 6px;
            padding: 6px 10px;
            margin-bottom: 10px;
        }

        /* ── 버튼 ── */
        .detail-link {
            margin-top: auto;
            text-align: center;
            padding: 8px 0;
            border-radius: 8px;
            background-color: #f1f3f5;
            color: #333;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            display: block;
        }

        .detail-link:hover { background-color: #e9ecef; }

        /* ── 페이지네이션 ── */
        .pagination { margin-top: 36px; text-align: center; }

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

        .page-btn:hover { background-color: #f1f3f5; }
        .page-btn.active { background-color: #9acd32; color: #111; }

        .empty {
            padding: 60px 0;
            text-align: center;
            color: #999;
            background-color: white;
            border-radius: 16px;
        }
    </style>
</head>
<body>
<div class="container">

    <h1>도서 목록</h1>

    <!-- ── 탭 버튼 ── -->
    <div class="tabs">
        <a href="?tab=all"
           class="tab-btn ${activeTab == 'all' ? 'active' : ''}">
            전체 목록
            <span class="tab-count">${bookPage.totalElements}</span>
        </a>
        <a href="?tab=bestseller"
           class="tab-btn ${activeTab == 'bestseller' ? 'active' : ''}">
            ⭐ 베스트셀러
            <span class="tab-count">${bestsellers.size()}</span>
        </a>
        <a href="?tab=discount"
           class="tab-btn ${activeTab == 'discount' ? 'active' : ''}">
            할인 중인 도서
            <span class="tab-count">${discounted.size()}</span>
        </a>
        <a href="?tab=gift"
           class="tab-btn ${activeTab == 'gift' ? 'active' : ''}">
            🎁 선착순 증정 이벤트
            <span class="tab-count">${giftEvent.size()}</span>
        </a>
    </div>

    <!-- ── 전체 목록 탭 ── -->
    <div class="tab-panel ${activeTab == 'all' ? 'active' : ''}">
        <c:choose>
            <c:when test="${empty books}">
                <div class="empty">등록된 도서가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="book-grid">
                    <c:forEach var="book" items="${books}">
                        <div class="book-card">
                            <a href="${pageContext.request.contextPath}/book/${book.isbn}">
                                <div class="thumb-wrap">
                                    <img src="${book.thumbnailUrl}" alt="${book.title}">
                                </div>
                            </a>
                            <div class="book-info">
                                <a class="book-title" href="${pageContext.request.contextPath}/book/${book.isbn}">${book.title}</a>
                                <div class="book-author">${book.author} · ${book.publisher}</div>
                                <div class="book-price">
                                    <c:choose>
                                        <c:when test="${book.hasDiscountTag and book.displayPrice != null}">
                                            <div class="price-row">
                                                <span class="discount-rate">${book.discountRate}%</span>
                                                <span class="sale-price">${book.displayPrice}원</span>
                                                <span class="original-price">${book.regularPrice}원</span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="regular-price">${book.regularPrice}원</span>
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
                                <a class="detail-link" href="${pageContext.request.contextPath}/book/${book.isbn}">상세보기</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="pagination">
                    <c:if test="${startPage > 0}">
                        <a href="?tab=all&page=${startPage - 10}" class="page-btn">이전</a>
                    </c:if>
                    <c:forEach begin="${startPage}" end="${endPage}" var="i">
                        <a href="?tab=all&page=${i}"
                           class="page-btn ${bookPage.number == i ? 'active' : ''}">${i + 1}</a>
                    </c:forEach>
                    <c:if test="${endPage < bookPage.totalPages - 1}">
                        <a href="?tab=all&page=${endPage + 1}" class="page-btn">다음</a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ── 베스트셀러 탭 ── -->
    <div class="tab-panel ${activeTab == 'bestseller' ? 'active' : ''}">
        <p class="section-desc">베스트셀러 순위 기준으로 정렬됩니다.</p>
        <c:choose>
            <c:when test="${empty bestsellers}">
                <div class="empty">베스트셀러 도서가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="book-grid">
                    <c:forEach var="book" items="${bestsellers}">
                        <div class="book-card">
                            <a href="${pageContext.request.contextPath}/book/${book.isbn}">
                                <div class="thumb-wrap">
                                    <span class="rank-num ${book.bestsellerRank <= 3 ? 'top3' : ''}">${book.bestsellerRank}</span>
                                    <img src="${book.thumbnailUrl}" alt="${book.title}">
                                </div>
                            </a>
                            <div class="book-info">
                                <a class="book-title" href="${pageContext.request.contextPath}/book/${book.isbn}">${book.title}</a>
                                <div class="book-author">${book.author} · ${book.publisher}</div>
                                <div class="book-price">
                                    <c:choose>
                                        <c:when test="${book.hasDiscountTag and book.displayPrice != null}">
                                            <div class="price-row">
                                                <span class="discount-rate">${book.discountRate}%</span>
                                                <span class="sale-price">${book.displayPrice}원</span>
                                                <span class="original-price">${book.regularPrice}원</span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="regular-price">${book.regularPrice}원</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="promo-tags">
                                    <span class="promo-tag tag-bestseller">⭐ 베스트셀러 ${book.bestsellerRank}위</span>
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
                                <a class="detail-link" href="${pageContext.request.contextPath}/book/${book.isbn}">상세보기</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ── 할인 탭 ── -->
    <div class="tab-panel ${activeTab == 'discount' ? 'active' : ''}">
        <p class="section-desc">할인율이 높은 순으로 정렬됩니다.</p>
        <c:choose>
            <c:when test="${empty discounted}">
                <div class="empty">할인 중인 도서가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="book-grid">
                    <c:forEach var="book" items="${discounted}">
                        <div class="book-card">
                            <a href="${pageContext.request.contextPath}/book/${book.isbn}">
                                <div class="thumb-wrap">
                                    <img src="${book.thumbnailUrl}" alt="${book.title}">
                                </div>
                            </a>
                            <div class="book-info">
                                <a class="book-title" href="${pageContext.request.contextPath}/book/${book.isbn}">${book.title}</a>
                                <div class="book-author">${book.author} · ${book.publisher}</div>
                                <div class="book-price">
                                    <div class="price-row">
                                        <span class="discount-rate">${book.discountRate}%</span>
                                        <span class="sale-price">${book.displayPrice}원</span>
                                        <span class="original-price">${book.regularPrice}원</span>
                                    </div>
                                </div>
                                <div class="highlight-info" style="color:#c0392b;">절약 금액 ${book.regularPrice - book.displayPrice}원</div>
                                <div class="promo-tags">
                                    <span class="promo-tag tag-discount">${book.discountRate}% 할인</span>
                                    <c:if test="${book.hasBestsellerTag}">
                                        <span class="promo-tag tag-bestseller">⭐ 베스트셀러 ${book.bestsellerRank}위</span>
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
                                <a class="detail-link" href="${pageContext.request.contextPath}/book/${book.isbn}">상세보기</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- ── 선착순 증정 탭 ── -->
    <div class="tab-panel ${activeTab == 'gift' ? 'active' : ''}">
        <p class="section-desc">진행 중인 이벤트가 먼저 표시됩니다. 잔여 수량이 소진되면 증정이 종료됩니다.</p>
        <c:choose>
            <c:when test="${empty giftEvent}">
                <div class="empty">진행 중인 증정 이벤트가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="book-grid">
                    <c:forEach var="book" items="${giftEvent}">
                        <div class="book-card">
                            <a href="${pageContext.request.contextPath}/book/${book.isbn}">
                                <div class="thumb-wrap">
                                    <img src="${book.thumbnailUrl}" alt="${book.title}">
                                </div>
                            </a>
                            <div class="book-info">
                                <a class="book-title" href="${pageContext.request.contextPath}/book/${book.isbn}">${book.title}</a>
                                <div class="book-author">${book.author} · ${book.publisher}</div>
                                <div class="book-price">
                                    <c:choose>
                                        <c:when test="${book.hasDiscountTag and book.displayPrice != null}">
                                            <div class="price-row">
                                                <span class="discount-rate">${book.discountRate}%</span>
                                                <span class="sale-price">${book.displayPrice}원</span>
                                                <span class="original-price">${book.regularPrice}원</span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="regular-price">${book.regularPrice}원</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:choose>
                                    <c:when test="${book.giftStatus eq 'SOLD_OUT'}">
                                        <div class="highlight-info" style="color:#999;">증정품 소진</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="highlight-info" style="color:#276749;">잔여 수량 ${book.giftRemainingQty}개</div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="promo-tags">
                                    <c:choose>
                                        <c:when test="${book.giftStatus eq 'SOLD_OUT'}">
                                            <span class="promo-tag tag-gift sold-out">증정품 소진</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="promo-tag tag-gift">🎁 선착순 증정 (${book.giftRemainingQty}개 남음)</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${book.hasBestsellerTag}">
                                        <span class="promo-tag tag-bestseller">⭐ 베스트셀러 ${book.bestsellerRank}위</span>
                                    </c:if>
                                    <c:if test="${book.hasDiscountTag}">
                                        <span class="promo-tag tag-discount">${book.discountRate}% 할인</span>
                                    </c:if>
                                </div>
                                <a class="detail-link" href="${pageContext.request.contextPath}/book/${book.isbn}">상세보기</a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div>
</body>
</html>
