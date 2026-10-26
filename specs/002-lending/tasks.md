# Tasks: 貸し出し

**Input**: `/specs/002-lending/` の spec.md・plan.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: ほかの Task と並行してできる
- **[Story]**: どのユーザーストーリーの Task か（US1、US2）

## Phase 1: Foundational

- [ ] T001 Loan モデルとテーブルを作る（src/models/loan.ts）

## Phase 2: User Story 1 - 本を貸し出す (Priority: P1)

**Goal**: 担当者が在庫のある本を貸し出せる
**Independent Test**: 本を 1 冊貸し出し、貸出中の一覧に出ることを確かめる

- [ ] T002 [US1] 貸出 API を作る（src/api/loans.ts）
- [ ] T008 [US1] 在庫がないときに貸し出せないようにする（src/api/loans.ts）
- [ ] T003 [US1] 貸出画面を作る（src/pages/loans/new.tsx）

## Phase 3: User Story 2 - 本を返却する (Priority: P2)

**Goal**: 担当者が貸出中の本を返却済みにできる
**Independent Test**: 貸出中の本を返却し、在庫が戻ることを確かめる

- [ ] T004 [P] [US2] 返却 API を作る（src/api/loans.ts）
- [ ] T005 [US2] 返却画面を作る（src/pages/loans/return.tsx）

## Phase 4: Polish

- [ ] T006 [P] 貸出と返却の E2E テストを書く（tests/e2e/lending.spec.ts）
- [ ] T007 README に貸し出しの使い方を書く

## Dependencies & Execution Order

- Phase 1 → Phase 2・3 → Phase 4 の順
- T001 は 001-book-register の T004（Book モデル）の後
- T008 は後から足した Task。ID は末尾の番号を使い、順番は並び（T002 の次）で表す。ほかの ID は振り直さない
