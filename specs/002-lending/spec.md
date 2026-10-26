# Feature Specification: 貸し出し

**Feature Branch**: `002-lending`
**Status**: Draft（サンプル）

## User Scenarios & Testing

### User Story 1 - 本を貸し出す (Priority: P1)

図書の担当者として、利用者に本を貸し出したい。誰が何を借りているかを記録するため。

**Independent Test**: 本を 1 冊貸し出し、貸出中の一覧に出ることを確かめる。

**Acceptance Scenarios**:

1. **Given** 在庫がある本, **When** 利用者に貸し出す, **Then** 貸出中の一覧に出て、在庫が 1 減る
2. **Given** 在庫がない本, **When** 貸し出そうとする, **Then** 貸し出せないと表示される

### User Story 2 - 本を返却する (Priority: P2)

図書の担当者として、返ってきた本を返却済みにしたい。

**Independent Test**: 貸出中の本を返却し、在庫が戻ることを確かめる。

**Acceptance Scenarios**:

1. **Given** 貸出中の本, **When** 返却する, **Then** 貸出中の一覧から消え、在庫が 1 増える

## Requirements

- **FR-001**: 担当者は在庫のある本を貸し出せる
- **FR-002**: 担当者は貸出中の本を返却済みにできる
- **FR-003**: 返却の期限は貸し出した日から 14 日とする

## Success Criteria

- **SC-001**: 貸し出しの操作が 30 秒以内に終わる
