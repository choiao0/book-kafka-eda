<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>도서 상세</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }
        h1 {
            color: #333;
        }
        .detail-container {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 8px;
            max-width: 500px;
        }
        .detail-row {
            margin-bottom: 15px;
        }
        .detail-label {
            font-weight: bold;
            color: #555;
            display: inline-block;
            width: 80px;
        }
        .detail-value {
            color: #333;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3c90e2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 20px;
            margin-right: 10px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        .btn:hover {
            background-color: #1C64D0;
        }
        .btn-edit {
            background-color: #3c90e2;
        }
        .btn-edit:hover {
            background-color: #1C64D0;
        }
        .btn-delete {
            background-color: #f44336;
        }
        .btn-delete:hover {
            background-color: #d32f2f;
        }
        .btn-back {
            background-color: #888;
        }
        .btn-back:hover {
            background-color: #666;
        }
        .button-group {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>도서 상세</h1>

    <div class="detail-container">
        <div class="detail-row">
            <span class="detail-label">ISBN:</span>
            <span class="detail-value">${book.isbn}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">제목:</span>
            <span class="detail-value">${book.title}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">저자:</span>
            <span class="detail-value">${book.author}</span>
        </div>
        <div class="detail-row">
            <span class="detail-label">가격:</span>
            <span class="detail-value">${book.price}원</span>
        </div>
    </div>

    <div class="button-group">
        <a href="${pageContext.request.contextPath}/book/${book.isbn}/edit" class="btn btn-edit">수정</a>
        <form action="${pageContext.request.contextPath}/book/${book.isbn}/delete"
              method="post" style="display:inline;"
              onsubmit="return confirm('정말 삭제하시겠습니까?');">
            <button type="submit" class="btn btn-delete">삭제</button>
        </form>
        <a href="${pageContext.request.contextPath}/book/list" class="btn btn-back">목록으로</a>
    </div>
</body>
</html>
