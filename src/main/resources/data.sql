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
-- 태그 조합별 더미 데이터 (첫 페이지 book_id 1~16 대상)
-- 3개 태그: 7 / 2개 태그: 6, 10, 1, 4 / 1개 태그: 11, 13, 15, 2, 5, 9 / 태그 없음: 3, 8, 12, 14, 16
INSERT INTO book_display_info
(book_id, has_bestseller_tag, bestseller_rank,
 has_discount_tag, discount_rate, display_price,
 has_gift_tag, gift_status, gift_remaining_qty,
 data_source, last_synced_at, created_at, updated_at)
VALUES
    -- [3개] 베스트셀러 + 할인 + 선착순 증정 : 달러구트 꿈 백화점 (24000원)
    (7,  1, 1,  1, 20, 19200,  1, 'ACTIVE',   50,  'BATCH', NOW(), NOW(), NOW()),

    -- [2개] 베스트셀러 + 선착순 증정        : 지리산 1 (18500원)
    (6,  1, 2,  0, NULL, NULL, 1, 'ACTIVE',   15,  'BATCH', NOW(), NOW(), NOW()),

    -- [2개] 베스트셀러 + 할인               : 개미 5년, 세후 55억 (17000원)
    (10, 1, 3,  1, 20, 13600,  0, NULL, NULL,      'BATCH', NOW(), NOW(), NOW()),

    -- [2개] 베스트셀러 + 할인               : 너에게 목소리를 보낼게 (16000원)
    (1,  1, 4,  1, 10, 14400,  0, NULL, NULL,      'BATCH', NOW(), NOW(), NOW()),

    -- [2개] 할인 + 선착순 증정 (소진)       : 즉시 기분을 바꿔드립니다 (14000원)
    (4,  0, NULL, 1, 15, 11900, 1, 'SOLD_OUT',  0, 'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 베스트셀러                      : 보통의 것이 좋아 (14800원)
    (11, 1, 5,  0, NULL, NULL,  0, NULL, NULL,     'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 할인                            : COSMOS 우주에 깃든 예술 (23000원)
    (13, 0, NULL, 1, 15, 19550, 0, NULL, NULL,     'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 할인                            : 천 번의 죽음이 내게 알려준 것들 (14000원)
    (15, 0, NULL, 1, 10, 12600, 0, NULL, NULL,     'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 선착순 증정 (ACTIVE)            : 일기에도 거짓말을 쓰는 사람 (15800원)
    (2,  0, NULL, 0, NULL, NULL, 1, 'ACTIVE',   12, 'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 선착순 증정 (ACTIVE)            : 오늘도 리추얼 (15000원)
    (5,  0, NULL, 0, NULL, NULL, 1, 'ACTIVE',   30, 'BATCH', NOW(), NOW(), NOW()),

    -- [1개] 선착순 증정 (SOLD_OUT)          : 마음이 허기질 때 (13000원)
    (9,  0, NULL, 0, NULL, NULL, 1, 'SOLD_OUT',  0, 'BATCH', NOW(), NOW(), NOW()),

    -- [없음]                                : 본격 한중일 세계사 12
    (3,  0, NULL, 0, NULL, NULL, 0, NULL, NULL,    'BATCH', NOW(), NOW(), NOW()),

    -- [없음]                                : 그린 스완
    (8,  0, NULL, 0, NULL, NULL, 0, NULL, NULL,    'BATCH', NOW(), NOW(), NOW()),

    -- [없음]                                : 신의 비밀, 징조
    (12, 0, NULL, 0, NULL, NULL, 0, NULL, NULL,    'BATCH', NOW(), NOW(), NOW()),

    -- [없음]                                : 2022 대한민국이 열광할 시니어 트렌드
    (14, 0, NULL, 0, NULL, NULL, 0, NULL, NULL,    'BATCH', NOW(), NOW(), NOW()),

    -- [없음]                                : 과학이 재밌어지는 아주 친절한 과학책
    (16, 0, NULL, 0, NULL, NULL, 0, NULL, NULL,    'BATCH', NOW(), NOW(), NOW());