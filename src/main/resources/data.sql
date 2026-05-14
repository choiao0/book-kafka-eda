-- book

# SET FOREIGN_KEY_CHECKS = 0; -- FK 비활성화
# TRUNCATE TABLE book;
# SET FOREIGN_KEY_CHECKS = 1; -- FK 다시 활성화

# TODO 1 : 도커 컨테이너 안에 csv 데이터 삽입
# docker cp /경로/book.csv book-kafka-eda-mysql-1:/var/lib/mysql-files/book.csv

# TODO 2 : 권한 설정
# docker exec -it book-kafka-eda-mysql-1 bash
# chmod 644 /var/lib/mysql-files/book.csv

# TODO 3 : mysql에 csv 데이터 연결
LOAD DATA INFILE '/var/lib/mysql-files/book.csv'
    INTO TABLE book
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (
     isbn,
     title,
     author,
     publisher,
     regular_price,
     content,
     thumbnail_url,
     @published_at
        )
    SET
        published_at =
                CASE
                    WHEN @published_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
                        AND @published_at NOT LIKE '%-00'
                        THEN STR_TO_DATE(@published_at, '%Y-%m-%d')
                    ELSE '2026-05-13'
                    END,
        created_at = NOW(),
        updated_at = NOW();

# 혜택 테이블 데이터 삭제
# TRUNCATE TABLE bestseller_promotion;
# TRUNCATE TABLE discount_promotion;
# TRUNCATE TABLE gift_promotion;

-- bestseller_promotion (첫 페이지 book_id 1~16 기준)
INSERT INTO bestseller_promotion
(book_id, ranking, list_type, valid_from, valid_until, published_at, created_at)
VALUES
    (7,  1, '주간', '2026-05-13 00:00:00', '2026-05-18 23:59:59', NOW(), NOW()),  -- 달러구트 꿈 백화점
    (6,  2, '주간', '2026-05-13 00:00:00', '2026-05-18 23:59:59', NOW(), NOW()),  -- 지리산 1
    (10, 3, '주간', '2026-05-13 00:00:00', '2026-05-18 23:59:59', NOW(), NOW()),  -- 개미 5년, 세후 55억
    (1,  4, '주간', '2026-05-13 00:00:00', '2026-05-18 23:59:59', NOW(), NOW()),  -- 너에게 목소리를 보낼게
    (11, 5, '주간', '2026-05-13 00:00:00', '2026-05-18 23:59:59', NOW(), NOW());  -- 보통의 것이 좋아



-- discount_promotion (첫 페이지 book_id 1~16 기준)
INSERT INTO discount_promotion
(book_id, discount_rate, discounted_price, valid_from, valid_until, published_at, created_at)
VALUES
    (7,  20, 19200, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),  -- 달러구트 꿈 백화점 24000 -> 19200
    (10, 20, 13600, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),  -- 개미 5년 세후 55억   17000 -> 13600
    (1,  10, 14400, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),  -- 너에게 목소리를 보낼게 16000 -> 14400
    (4,  15, 11900, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),  -- 즉시 기분을 바꿔드립니다 14000 -> 11900
    (13, 15, 19550, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),  -- COSMOS 우주에 깃든 예술 23000 -> 19550
    (15, 10, 12600, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW());  -- 천 번의 죽음이 내게 알려준 것들 14000 -> 12600



-- gift_promotion (첫 페이지 book_id 1~16 기준)
INSERT INTO gift_promotion
(book_id, gift_name, total_quantity, remaining_quantity, status,
 valid_from, valid_until, published_at, created_at, updated_at)
VALUES
    (7,  '달러구트 엽서 세트',   100, 50, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),  -- 달러구트 꿈 백화점

    (6,  '지리산 드라마 포스터',  30, 15, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),  -- 지리산 1

    (4,  '마음 치유 북마크',      50,  0, 'SOLD_OUT',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),  -- 즉시 기분을 바꿔드립니다

    (2,  '감성 일기 노트',        80, 12, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),  -- 일기에도 거짓말을 쓰는 사람

    (5,  '리추얼 플래너',         60, 30, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),  -- 오늘도 리추얼

    (9,  '독서 레시피 카드',      70,  0, 'SOLD_OUT',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW());  -- 마음이 허기질 때

-- book_display_info : 배치(DisplayInfoBatchJob)가 기동 후 30초 이내에 자동으로 채워줌