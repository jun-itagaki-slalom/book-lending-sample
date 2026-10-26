# Tasks: 本の登録

**Input**: `/specs/001-book-register/` の spec.md・plan.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: ほかの Task と並行してできる
- **[Story]**: どのユーザーストーリーの Task か（US1、US2）

## Phase 1: Setup

- [ ] T001 プロジェクトの構成を作る（src/、tests/）
- [ ] T002 [P] Lint と Formatter を設定する

## Phase 2: Foundational

- [ ] T003 DB の接続とマイグレーションの仕組みを作る（src/db/）

## Phase 3: User Story 1 - 本を登録する (Priority: P1)

**Goal**: 担当者が本を登録できる
**Independent Test**: 本を 1 冊登録し、一覧に表示されることを確かめる

- [ ] T004 [P] [US1] Book モデルとテーブルを作る（src/models/book.ts）
- [ ] T005 [US1] 本の登録 API を作る（src/api/books.ts）
- [ ] T006 [US1] 本の登録画面を作る（src/pages/books/new.tsx）

## Phase 4: User Story 2 - 本を検索する (Priority: P2)

**Goal**: 利用者がタイトル・著者で本を探せる
**Independent Test**: タイトルの一部で検索し、該当する本が出ることを確かめる

- [ ] T007 [P] [US2] 本の検索 API を作る（src/api/books.ts）
- [ ] T008 [US2] 本の検索画面を作る（src/pages/books/index.tsx）

## Phase 5: Polish

- [ ] T009 README に使い方を書く

## Dependencies & Execution Order

- Phase 1 → Phase 2 → Phase 3・4 → Phase 5 の順
- T004 は T003 の後
