-- book

# SET FOREIGN_KEY_CHECKS = 0; -- FK 비활성화
# TRUNCATE TABLE book;
# SET FOREIGN_KEY_CHECKS = 1; -- FK 다시 활성화

# TODO 3 : 도커 컨테이너 안에 csv 데이터 삽입
# docker cp /Users/kimsohui/books.csv book-kafka-eda-mysql-1:/books.csv

# TODO 4 : mysql에 csv 데이터 연결
LOAD DATA INFILE '/books.csv' -- 컨테이너 내부 경로
    INTO TABLE book
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
         published_at
        )
    SET
        created_at = NOW(),
        updated_at = NOW();

-- bestseller_promotion (1~5위)
INSERT INTO bestseller_promotion (book_id, ranking, list_type, valid_from, valid_until, published_at, created_at) VALUES
                                                                                                                     (1, 1, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
                                                                                                                     (3, 2, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
                                                                                                                     (7, 3, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
                                                                                                                     (8, 4, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW()),
                                                                                                                     (2, 5, '주간', '2026-05-06 00:00:00', '2026-05-12 23:59:59', NOW(), NOW());

-- discount_promotion
INSERT INTO discount_promotion (book_id, discount_rate, discounted_price, valid_from, valid_until, published_at, created_at) VALUES
                                                                                                                                 (1, 10, 19800, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),
                                                                                                                                 (3, 15, 30600, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),
                                                                                                                                 (5, 20, 27200, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW()),
                                                                                                                                 (9, 10, 11700, '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW());

-- gift_promotion (선착순 증정 — remaining_quantity 낮게 설정해서 정합성 깨짐 시나리오용)
INSERT INTO gift_promotion (book_id, gift_name, total_quantity, remaining_quantity, status, valid_from, valid_until, published_at, created_at, updated_at) VALUES
                                                                                                                                                               (2, '에코백 증정', 50, 3, 'ACTIVE', '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),
                                                                                                                                                               (4, '북마크 세트 증정', 30, 0, 'SOLD_OUT', '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW()),
                                                                                                                                                               (7, '친필 사인 증정', 10, 7, 'ACTIVE', '2026-05-01 00:00:00', '2026-05-31 23:59:59', NOW(), NOW(), NOW());

-- book_display_info (배치가 집계한 전시 데이터 — 배치 방식 시뮬레이션)
INSERT INTO book_display_info (book_id, has_bestseller_tag, bestseller_rank, has_discount_tag, discount_rate, display_price, has_gift_tag, gift_status, gift_remaining_qty, data_source, last_synced_at, created_at, updated_at) VALUES
                                                                                                                                                                                                                                     (1,  1, 1, 1, 10, 19800, 0, NULL, NULL,  'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (2,  1, 5, 0, NULL, 18000, 1, 'ACTIVE', 3, 'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (3,  1, 2, 1, 15, 30600, 0, NULL, NULL,  'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (4,  0, NULL, 0, NULL, 43000, 1, 'ACTIVE', 0, 'BATCH', NOW(), NOW(), NOW()),  -- ← 핵심 정합성 문제! display는 ACTIVE인데 실제 remaining=0
                                                                                                                                                                                                                                     (5,  0, NULL, 1, 20, 27200, 0, NULL, NULL,  'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (6,  0, NULL, 0, NULL, 16800, 0, NULL, NULL, 'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (7,  1, 3, 0, NULL, 12000, 1, 'ACTIVE', 7, 'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (8,  1, 4, 0, NULL, 13800, 0, NULL, NULL,  'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (9,  0, NULL, 1, 10, 11700, 0, NULL, NULL,  'BATCH', NOW(), NOW(), NOW()),
                                                                                                                                                                                                                                     (10, 0, NULL, 0, NULL, 9800,  0, NULL, NULL, 'BATCH', NOW(), NOW(), NOW());