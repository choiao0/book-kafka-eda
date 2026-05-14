-- 실행 : CALL refresh_book_display_info();

-- 정합성 깨짐 테스트
--
-- 1. 원본 gift_promotion은 SOLD_OUT
UPDATE gift_promotion
SET remaining_quantity = 100,
    status = 'ACTIVE'
WHERE book_id = 7;


UPDATE gift_promotion
SET remaining_quantity = 0,
    status = 'SOLD_OUT'
WHERE book_id = 7;

--
-- 2. book_display_info에는 선착순 태그가 남아 있습니다
-- SELECT *
-- FROM book_display_info
-- WHERE book_id = 1;


# bestseller_promotion : 하루에 한 번 처리
# discount_promotion : 실시간 처리 필요 (현재는 배치)
# gift_promotion : 선착순 증정품 제공 - 실시간 처리 필요 (현재는 배치)


DELIMITER //

DROP PROCEDURE IF EXISTS refresh_book_display_info //

CREATE PROCEDURE refresh_book_display_info()
BEGIN
DELETE FROM book_display_info;

INSERT INTO book_display_info (
    book_id,
    has_bestseller_tag,
    bestseller_rank,
    has_discount_tag,
    discount_rate,
    display_price,
    has_gift_tag,
    gift_status,
    gift_remaining_qty,
    data_source,
    last_synced_at
)
SELECT
    b.book_id,

    CASE
        WHEN bp.promotion_id IS NOT NULL THEN 1
        ELSE 0
        END AS has_bestseller_tag,

    bp.ranking AS bestseller_rank,

    CASE
        WHEN dp.promotion_id IS NOT NULL THEN 1
        ELSE 0
        END AS has_discount_tag,

    dp.discount_rate AS discount_rate,

    CASE
        WHEN dp.promotion_id IS NOT NULL
            THEN dp.discounted_price
        ELSE b.regular_price
        END AS display_price,

    CASE
        WHEN gp.promotion_id IS NOT NULL
            AND gp.status = 'ACTIVE'
            AND gp.remaining_quantity > 0
            THEN 1
        ELSE 0
        END AS has_gift_tag,

    gp.status AS gift_status,

    gp.remaining_quantity AS gift_remaining_qty,

    'BATCH' AS data_source,

    NOW() AS last_synced_at

FROM book b

         LEFT JOIN bestseller_promotion bp
                   ON b.book_id = bp.book_id
                       AND NOW() BETWEEN bp.valid_from AND bp.valid_until

         LEFT JOIN discount_promotion dp
                   ON b.book_id = dp.book_id
                       AND NOW() BETWEEN dp.valid_from AND dp.valid_until

         LEFT JOIN gift_promotion gp
                   ON b.book_id = gp.book_id
                       AND NOW() BETWEEN gp.valid_from AND gp.valid_until;
END //

DELIMITER ;