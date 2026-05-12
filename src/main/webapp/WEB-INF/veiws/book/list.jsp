<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>도서 목록</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #3c90e2;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3c90e2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 20px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        .btn:hover {
            background-color: #1C64D0;
        }
        .btn-delete {
            background-color: #f44336;
            padding: 5px 10px;
            margin-top: 0;
        }
        .btn-delete:hover {
            background-color: #d32f2f;
        }
        a {
            color: #3c90e2;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .action-cell {
            display: flex;
            gap: 10px;
            align-items: center;
        }
    </style>
</head>
<body>
    <h1>도서 목록</h1>

    <a href="${pageContext.request.contextPath}/book/regist" class="btn">새 도서 등록</a>

    <table>
        <thead>
            <tr>
                <th>ISBN</th>
                <th>제목</th>
                <th>저자</th>
                <th>가격</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="book" items="${books}">
                <tr>
                    <td>${book.isbn}</td>
                    <td><a href="${pageContext.request.contextPath}/book/${book.isbn}">${book.title}</a></td>
                    <td>${book.author}</td>
                    <td>${book.price}원</td>
                    <td class="action-cell">
                        <a href="${pageContext.request.contextPath}/book/${book.isbn}">상세</a>
                        <form action="${pageContext.request.contextPath}/book/${book.isbn}/delete"
                              method="post" style="display:inline;"
                              onsubmit="return confirm('정말 삭제하시겠습니까?');">
                            <button type="submit" class="btn btn-delete">삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty books}">
                <tr>
                    <td colspan="5" style="text-align: center;">등록된 도서가 없습니다.</td>
                </tr>
            </c:if>
        </tbody>
    </table>
</body>
</html>
