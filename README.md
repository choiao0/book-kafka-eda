# book-kafka-eda 실습 로드맵
배치 기반 도서 프로모션 시스템의 데이터 정합성 문제를 Kafka EDA로 전환해 해결하는 실습 프로젝트

 
## Overview
 
배치 기반 도서 프로모션 시스템에서 발생하는 **데이터 정합성 문제**를 재현하고, Kafka EDA(Event-Driven Architecture)로 전환해 해결하는 실습 프로젝트입니다.
 
올리브영 테크블로그 [45분 배치에서 준실시간으로](https://oliveyoung.tech/2026-04-22/display-benefits-migration/)의 구조를 Book 도메인으로 재해석했습니다.


 
## Problem
 
```
[기존 문제 — 배치 단일 프로시저 방식]
 
Spring Batch (주기적 실행)
  → BOOK_DISPLAY_INFO 전체 재갱신
  → 카드 목록: gift_status = ACTIVE  ❌
  → 실제 DB:   remaining_quantity = 0 (이미 마감)
 
고객이 카드에서 "선착순 증정" 태그를 보고 상세 진입
→ 혜택이 이미 마감된 상태 → 데이터 정합성 깨짐
```
 
 
## Solution
 
```
[EDA 전환 — Kafka 이벤트 기반]
 
선착순 구매 발생
  → GIFT_PROMOTION.remaining_quantity 감소
  → Kafka topic: book.promotion.gift 이벤트 발행
  → Consumer: BOOK_DISPLAY_INFO 즉시 UPSERT
  → 카드/상세 모두 동일한 최신 데이터 반영  ✅
```
 
 
## Tech Stack
 
| 구분 | 기술 |
|------|------|
| Language | Java 17 |
| Framework | Spring Boot 3, Spring Batch, Spring Kafka |
| Database | MySQL 8 |
| Message Broker | Apache Kafka |
| Infra | Docker, Docker Compose |
| UI | Kafdrop (Kafka 모니터링) |
 
 
## Architecture
 
### 하이브리드 처리 전략
 
| 프로모션 | 처리 방식 | 이유 |
|----------|-----------|------|
| 베스트셀러 | Spring Batch | 변경 주기가 길어 배치로 충분 |
| 할인 | Kafka 이벤트 | 수시 변경, 즉시 반영 필요 |
| 선착순 증정 | Kafka 이벤트 | 재고 소진 즉시 반영 필수 |


## 구현 과정

<img width="738" height="548" alt="스크린샷 2026-05-12 오후 8 37 11" src="https://github.com/user-attachments/assets/156fdf81-1849-4652-bf80-d3944f8196ca" />

<img width="738" height="433" alt="스크린샷 2026-05-12 오후 8 37 29" src="https://github.com/user-attachments/assets/e2dc2220-287b-4bb5-b3c4-448bbf07f126" />

<img width="738" height="236" alt="스크린샷 2026-05-12 오후 8 37 49" src="https://github.com/user-attachments/assets/97623a6e-00d7-4adc-9b61-61f45d229036" />


## Database Schema

### ERD 설계
<img width="1440" height="2024" alt="image" src="https://github.com/user-attachments/assets/2d7903cc-a98d-4e98-a2f0-7924446ad072" />

### 테이블 설명

- `BOOK` — 도서 마스터 (isbn, 정가 등 불변 데이터)
- `BESTSELLER_PROMOTION` — 베스트셀러 순위 (list_type으로 주간/월간 구분)
- `DISCOUNT_PROMOTION` — 할인 정보 (valid_from/until로 유효 기간 관리)
- `GIFT_PROMOTION` — 선착순 증정 (**핵심 문제 테이블**, remaining_quantity 실시간 감소)
- `BOOK_DISPLAY_INFO` — 전시 집계 테이블 (카드/상세가 이 테이블 단일 조회)
- `BATCH_JOB_LOG` — Spring Batch 실행 이력
- `KAFKA_EVENT_LOG` — 이벤트 발행/소비 이력


<img width="751" height="497" alt="스크린샷 2026-05-15 오전 11 03 58" src="https://github.com/user-attachments/assets/fcec7f3f-0ebd-4b25-95aa-06266b4524a9" />
<img width="751" height="426" alt="스크린샷 2026-05-15 오전 11 04 18" src="https://github.com/user-attachments/assets/6940bcf8-fb43-44f2-8b03-25a0f2c98fae" />



## References
 
- [올리브영 테크블로그 — 45분 배치에서 준실시간으로](https://oliveyoung.tech/2026-04-22/display-benefits-migration/)
 
