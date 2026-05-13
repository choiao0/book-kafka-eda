
기존 구조에서는 API가 각 도메인 테이블을 직접 조회하지 않고,
배치 프로시저가 생성한 book_display_info 조회용 테이블을 참조했습니다.

(초기 프로시저 기반 개발 이유 : 조회 API를 빠르고 단순하게 만들기 위해서)
복잡한 계산은 배치 프로시저가 미리 해둔다 > API는 book_display_info만 빠르게 읽는다

(장점)
1. API 조회 속도가 빠름
2. 조회 로직이 단순함
3. 복잡한 할인/혜택 계산을 DB 프로시저에 몰아둘 수 있음
4. 트래픽이 많아도 API 서버 부담이 작음
5. 초기에 개발 속도가 빠름

---

(단점)


초기에는 조회 성능과 개발 단순성을 위해 여러 도메인 데이터를 배치 프로시저로 미리 계산해 book_display_info에 저장하는 구조를 선택했을 가능성이 큽니다. API는 복잡한 조인이나 조건 계산 없이 조회용 테이블만 읽으면 되기 때문에 응답 속도가 빠르고 구현도 단순합니다.

하지만 서비스가 커지면서 베스트셀러, 할인, 선착순 증정품처럼 데이터 변경 주기와 실시간성 요구사항이 다른 도메인이 같은 배치 흐름에 묶이는 문제가 생겼습니다. 특히 할인과 증정품은 원본 상태가 바뀌면 화면에도 즉시 반영되어야 하는데, 기존 구조에서는 다음 배치가 돌기 전까지 book_display_info가 갱신되지 않아 정합성 문제가 발생했습니다.

(사례)

gift_promotion의 상태가 SOLD_OUT으로 바뀌어도
프로시저가 다시 실행되기 전까지 조회용 테이블에는 GIFT 태그가 남아 있었습니다.

(프로시저 동작 과정)

```
gift_promotion
discount_promotion
bestseller_promotion
↓
배치 프로시저(refresh_book_display_info)
↓
book_display_info
↓
상품 목록 / 상세 API
```

배치 프로시저는 여러 프로모션 도메인의 상태를 종합해 `promotion_tags` 값을 계산

```agsl
BESTSELLER
DISCOUNT
GIFT
```

```agsl
bestseller_promotion
→ 하루 1회 갱신이면 충분

discount_promotion
→ 가격 정책 변경 시 즉시 반영 필요

gift_promotion
→ 재고 소진 즉시 품절 처리 필요
```

특히 gift_promotion은 선착순 증정품 이벤트였기 때문에 재고가 소진되면 즉시 화면에서 제거되어야 했습니다.

하지만 기존 구조에서는 다음 배치가 실행되기 전까지 book_display_info가 갱신되지 않았습니다.

그 결과 원본 데이터와 조회 데이터 사이의 정합성 문제가 발생했습니다.


---

시나리오

백오피스 테스트 화면에서 원본 데이터, 조회용 데이터, API 응답을 나란히 비교해
정합성 깨짐을 가시적으로 확인했습니다.

```agsl
gift_promotion
- remaining_quantity = 1
- status = ACTIVE

book_display_info
- promotion_tags = BESTSELLER,GIFT
```

사용자 상품 조회 API
```agsl
GET /api/books/1
```
응답 (json)
```agsl
{
  "bookId": 1,
  "promotionTags": ["BESTSELLER", "GIFT"]
}
```

이후 선착순 증정품 재고가 모두 소진되어 원본 데이터가 변경되었습니다.

```agsl
UPDATE gift_promotion
SET remaining_quantity = 0,
    status = 'SOLD_OUT'
WHERE book_id = 1;
```

하지만 book_display_info는 배치 프로시저가 아직 실행되지 않은 상태였습니다.

따라서 API는 여전히 이전 조회 데이터를 반환했습니다.

```agsl
{
  "bookId": 1,
  "promotionTags": ["BESTSELLER", "GIFT"]
}
```

즉 실제로는 증정품이 종료되었음에도 사용자 화면에는 여전히 “선착순 증정” 태그가 노출되는 문제가 발생했습니다.

