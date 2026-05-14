package com.yesolive.bookstore.kafka.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Kafka 이벤트 처리 지표 조회 API.
 *
 * GET /kafka/metrics         → 요약 + 최근 이벤트 목록
 * GET /kafka/metrics?limit=N → 최근 N건 조회 (기본 20)
 */
@RestController
@RequestMapping("/kafka/metrics")
public class KafkaMetricsController {

    private final JdbcTemplate jdbcTemplate;

    public KafkaMetricsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> metrics(
            @RequestParam(defaultValue = "20") int limit) {

        // ── 요약 집계 ──────────────────────────────────────────────────────────
        Map<String, Object> summary = jdbcTemplate.queryForMap("""
                SELECT
                    COUNT(*)                                                AS total,
                    SUM(status = 'CONSUMED')                               AS consumed,
                    SUM(status = 'PUBLISHED')                              AS pending,
                    SUM(status = 'FAILED')                                 AS failed,
                    ROUND(AVG(TIMESTAMPDIFF(MICROSECOND, published_at, consumed_at) / 1000.0), 2)
                                                                           AS avg_latency_ms,
                    ROUND(MIN(TIMESTAMPDIFF(MICROSECOND, published_at, consumed_at) / 1000.0), 2)
                                                                           AS min_latency_ms,
                    ROUND(MAX(TIMESTAMPDIFF(MICROSECOND, published_at, consumed_at) / 1000.0), 2)
                                                                           AS max_latency_ms
                FROM kafka_event_log
                WHERE consumed_at IS NOT NULL
                """);

        // ── 최근 이벤트 목록 ───────────────────────────────────────────────────
        List<Map<String, Object>> events = jdbcTemplate.queryForList("""
                SELECT
                    event_id,
                    topic,
                    event_type,
                    ref_id                                                  AS book_id,
                    status,
                    published_at,
                    consumed_at,
                    ROUND(TIMESTAMPDIFF(MICROSECOND, published_at, consumed_at) / 1000.0, 2)
                                                                            AS latency_ms
                FROM kafka_event_log
                ORDER BY event_id DESC
                LIMIT ?
                """, limit);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("queriedAt", LocalDateTime.now().toString());
        result.put("summary", summary);
        result.put("events", events);

        return ResponseEntity.ok(result);
    }
}
