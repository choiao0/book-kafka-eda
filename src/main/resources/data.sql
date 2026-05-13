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

-- bestseller_promotion
INSERT INTO bestseller_promotion
(book_id, ranking, list_type, valid_from, valid_until, published_at, created_at)
VALUES
    (8198, 1, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
    (8197, 2, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
    (8201, 3, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
    (8192, 4, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
    (8195, 5, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW());



-- discount_promotion
INSERT INTO discount_promotion
(book_id, discount_rate, discounted_price, valid_from, valid_until, published_at, created_at)
VALUES
    -- 24000 -> 19200
    (8198, 20, 19200, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),

    -- 18500 -> 16650
    (8197, 10, 16650, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),

    -- 17000 -> 13600
    (8201, 20, 13600, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),

    -- 16000 -> 14400
    (8192, 10, 14400, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW());



-- gift_promotion
INSERT INTO gift_promotion
(book_id, gift_name, total_quantity, remaining_quantity, status,
 valid_from, valid_until, published_at, created_at, updated_at)
VALUES
    (8193, '시인 엽서 세트', 100, 12, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59',
     NOW(), NOW(), NOW()),

    (8195, '마음 치유 북마크', 50, 0, 'SOLD_OUT',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59',
     NOW(), NOW(), NOW()),

    (8197, '지리산 드라마 포스터', 30, 4, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59',
     NOW(), NOW(), NOW()),

    (8200, '독서 레시피 카드', 70, 25, 'ACTIVE',
     '2026-05-01 00:00:00', '2026-05-31 23:59:59',
     NOW(), NOW(), NOW());



-- book_display_info
INSERT INTO book_display_info
(book_id,
 has_bestseller_tag,
 bestseller_rank,
 has_discount_tag,
 discount_rate,
 display_price,
 has_gift_tag,
 gift_status,
 gift_remaining_qty,
 data_source,
 last_synced_at,
 created_at,
 updated_at)
VALUES

    -- 달러구트 꿈 백화점
    (8198, 1, 1, 1, 20, 19200,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 지리산
    (8197, 1, 2, 1, 10, 16650,
     1, 'ACTIVE', 4,
     'BATCH', NOW(), NOW(), NOW()),

    -- 개미 5년 세후 55억
    (8201, 1, 3, 1, 20, 13600,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 너에게 목소리를 보낼게
    (8192, 1, 4, 1, 10, 14400,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 즉시 기분을 바꿔드립니다
    (8195, 1, 5, 0, NULL, 14000,
     1, 'ACTIVE', 0,
     'BATCH', NOW(), NOW(), NOW()),

    -- 일기에도 거짓말을 쓰는 사람
    (8193, 0, NULL, 0, NULL, 15800,
     1, 'ACTIVE', 12,
     'BATCH', NOW(), NOW(), NOW()),

    -- 본격 한중일 세계사
    (8194, 0, NULL, 0, NULL, 14800,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 오늘도 리추얼
    (8196, 0, NULL, 0, NULL, 15000,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 그린 스완
    (8199, 0, NULL, 0, NULL, 17000,
     0, NULL, NULL,
     'BATCH', NOW(), NOW(), NOW()),

    -- 마음이 허기질 때 어린이책에서 꺼내 먹은 것들
    (8200, 0, NULL, 0, NULL, 13000,
     1, 'ACTIVE', 25,
     'BATCH', NOW(), NOW(), NOW());