DROP TABLE IF EXISTS kafka_event_log;
DROP TABLE IF EXISTS batch_job_log;
DROP TABLE IF EXISTS book_display_info;
DROP TABLE IF EXISTS gift_promotion;
DROP TABLE IF EXISTS discount_promotion;
DROP TABLE IF EXISTS bestseller_promotion;
DROP TABLE IF EXISTS book;

CREATE TABLE book (
                      book_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
                      isbn          VARCHAR(20)  NOT NULL UNIQUE,
                      title         VARCHAR(200) NOT NULL,
                      author        VARCHAR(100) NOT NULL,
                      publisher     VARCHAR(100),
                      regular_price INT          NOT NULL,
                      category      VARCHAR(50),
                      thumbnail_url VARCHAR(500),
                      published_at  DATETIME,
                      created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE bestseller_promotion (
                                      promotion_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                      book_id      BIGINT      NOT NULL,
                                      ranking       INT         NOT NULL,
                                      list_type    VARCHAR(20) NOT NULL COMMENT '주간/월간/장르별',
                                      valid_from   DATETIME    NOT NULL,
                                      valid_until  DATETIME    NOT NULL,
                                      published_at DATETIME    NOT NULL,
                                      created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE discount_promotion (
                                    promotion_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
                                    book_id          BIGINT   NOT NULL,
                                    discount_rate    INT      NOT NULL,
                                    discounted_price INT      NOT NULL,
                                    valid_from       DATETIME NOT NULL,
                                    valid_until      DATETIME NOT NULL,
                                    published_at     DATETIME NOT NULL,
                                    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE gift_promotion (
                                promotion_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
                                book_id            BIGINT       NOT NULL,
                                gift_name          VARCHAR(200) NOT NULL,
                                total_quantity     INT          NOT NULL,
                                remaining_quantity INT          NOT NULL,
                                status             VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/SOLD_OUT/EXPIRED',
                                valid_from         DATETIME     NOT NULL,
                                valid_until        DATETIME     NOT NULL,
                                published_at       DATETIME     NOT NULL,
                                created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE book_display_info (
                                   display_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   book_id            BIGINT     NOT NULL UNIQUE,
                                   has_bestseller_tag TINYINT(1) NOT NULL DEFAULT 0,
                                   bestseller_rank    INT,
                                   has_discount_tag   TINYINT(1) NOT NULL DEFAULT 0,
                                   discount_rate      INT,
                                   display_price      INT,
                                   has_gift_tag       TINYINT(1) NOT NULL DEFAULT 0,
                                   gift_status        VARCHAR(20),
                                   gift_remaining_qty INT,
                                   data_source        VARCHAR(20) COMMENT 'BATCH/EVENT',
                                   last_synced_at     DATETIME,
                                   created_at         DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   updated_at         DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   FOREIGN KEY (book_id) REFERENCES book (book_id)
);

CREATE TABLE batch_job_log (
                               log_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                               job_name        VARCHAR(100) NOT NULL,
                               status          VARCHAR(20)  NOT NULL COMMENT 'STARTED/COMPLETED/FAILED',
                               processed_count INT          NOT NULL DEFAULT 0,
                               failed_count    INT          NOT NULL DEFAULT 0,
                               started_at      DATETIME     NOT NULL,
                               finished_at     DATETIME,
                               error_message   TEXT
);

CREATE TABLE kafka_event_log (
                                 event_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
                                 topic        VARCHAR(100) NOT NULL,
                                 event_type   VARCHAR(50)  NOT NULL,
                                 ref_id       BIGINT       NOT NULL,
                                 payload      TEXT,
                                 status       VARCHAR(20)  NOT NULL COMMENT 'PUBLISHED/CONSUMED/FAILED',
                                 published_at DATETIME     NOT NULL,
                                 consumed_at  DATETIME
);