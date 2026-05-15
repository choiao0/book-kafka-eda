## CDC 기반 Kafka 이벤트 스트림 구조로 선착순 증정 이벤트 정합성 개선

### 개요



기존 배치 기반 구조는 조회 성능을 단순하게 확보할 수 있다는 장점이 있었지만, 실시간성이 필요한 선착순 증정 이벤트에는 적합하지 않았습니다.
`gift_promotion`의 증정품 재고가 소진되어도 다음 배치가 실행되기 전까지 `book_display_info`가 갱신되지 않아, 상품 목록 화면과 상세 화면의 데이터가 다르게 보이는 문제가 발생했기 떄문입니다.

본 프로젝트는 이러한 문제를 개선하기 위해 선착순 증정 이벤트 도메인을 Kafka 이벤트 기반 구조로 분리하고, 증정품 상태 변경 시 `book_display_info`를 즉시 갱신하는 구조를 구현했습니다.

이를 통해 상품 목록과 상세 화면 간 데이터 불일치를 줄이고, 전체 배치 재계산으로 인한 불필요한 DB 읽기와 갱신을 줄일 수 있었습니다.

---

### 개선 목표

기존 구조의 문제는 모든 프로모션 도메인을 하나의 배치 흐름으로 처리했다는 점입니다.

특히 `gift_promotion`은 재고 소진 여부가 사용자 경험에 직접 영향을 주기 때문에, 배치 주기를 기다리는 방식보다 상태 변경 즉시 반영되는 구조가 필요했습니다.


```text
기존 구조

gift_promotion 변경
→ 다음 배치 실행 대기
→ book_display_info 갱신
→ 상품 목록 화면 반영
```
```text
개선 구조

gift_promotion 변경
→ Kafka 이벤트 발행
→ Consumer 이벤트 수신
→ book_display_info 즉시 갱신
→ 상품 목록 화면 반영
```


---
### 전체 아키텍처


```agsl
상품 구매, 증정품 재고 소진 API 호출
            ↓
1. GiftPromotionController
            ↓
2. GiftPromotionService
            ↓
3. gift_promotion 상태 변경
   (증정품이 소진되면 gift_promotion 상태를 SOLD_OUT으로 변경하고 Kafka 이벤트를 발행한다)
            ↓
4. GiftPromotionProducer
   (Producer는 Kafka 메시지를 발행하기 전에 kafka_event_log에 이벤트 이력을 먼저 저장한다)
            ↓
5. Kafka Topic
   book.promotion.gift (채널)
            ↓
6. GiftPromotionConsumer 
   (Consumer는 Kafka 메시지를 수신하면 book_display_info를 즉시 갱신한다)
            ↓
7. book_display_info 즉시 갱신
            ↓
상품 목록 화면 반영
```

---
### 실시간으로 선착순 증정품 재고 변경 현황을 반영하는 이벤트 스트림 기반 시나리오 재현


1. 초기 상태
- 상품 목록 화면 (선착순 증정 이벤트 진행 중, 남은 수량 : 100)
- 상품 상세 화면 (선착순 증정 이벤트 진행 중, 남은 수량 : 100)
  
2. CDC 기반 Kafka 이벤트 스트림 구조 구현

<img width="794" height="598" alt="스크린샷 2026-05-15 오전 10 29 14" src="https://github.com/user-attachments/assets/8fc11cc9-09d0-47c6-8433-29e020caa653" />


3. Kafka 이벤트 스트림 구조를 통해, 증정품 재고 소진 후 `list.jsp`에 변경 현황 즉시 반영됨

<img width="663" height="432" alt="스크린샷 2026-05-15 오전 10 36 41" src="https://github.com/user-attachments/assets/8ad7a8c6-2a4b-4fe6-9ca2-e98ba5e024fd" />


---
### 기존 배치 구조와 Kafka 이벤트 기반 구조 비교

| 구분     | 기존 배치 구조      | Kafka 이벤트 기반 구조                  |
| ------ | ------------- | -------------------------------- |
| 처리 방식  | 주기적 전체 갱신     | 변경 이벤트 기반 즉시 갱신                  |
| 반영 시점  | 다음 배치 실행 후    | Kafka Consumer 처리 직후             |
| 정합성 문제 | 배치 전까지 불일치 가능 | 상태 변경 즉시 동기화                     |
| DB 부하  | 전체 데이터 재계산    | 변경된 상품만 처리                       |
| 관측 가능성 | 배치 로그 중심      | 이벤트 로그, 지연 시간, Consumer 상태 확인 가능 |



---
### 개선 효과


1. 데이터 정합성 개선
   - 개선 전
     - 상품 상세 화면은 원본 테이블을 직접 조회하고, 상품 목록 화면은 배치 결과 테이블을 조회했기 때문에 두 화면 간 상태 불일치가 발생했습니다.

   - 개선 후 
     - Kafka 이벤트 기반 구조에서는 `gift_promotion` 상태 변경 시 `book_display_info`를 즉시 갱신하므로, 상품 목록과 상세 화면의 상태 차이를 줄일 수 있습니다.


2. DB I/O 감소

   - 개선 전
     - 배치 구조는 `book_display_info` 전체 프로모션 데이터를 반복적으로 재계산했습니다.
   - 개선 후
     - `변경된 상품의 이벤트만 처리`하므로 불필요한 전체 조회와 갱신을 줄일 수 있습니다.
     <img width="1059" height="136" alt="스크린샷 2026-05-15 오전 10 48 58" src="https://github.com/user-attachments/assets/8e8c083d-15ce-4482-b39c-7e5e4580410d" />



3. 운영 관측성
   - kafka_event_log를 통해 이벤트의 발행, 소비, 처리 지연 시간을 확인할 수 있습니다. 
        ```
        PUBLISHED → CONSUMED
        published_at → consumed_at
        latency_ms 측정
        ```
