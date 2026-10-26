# Feature Specification: 本の登録

**Feature Branch**: `001-book-register`
**Status**: Draft（サンプル）

## User Scenarios & Testing

### User Story 1 - 本を登録する (Priority: P1)

図書の担当者として、新しく入った本を登録したい。貸し出しの対象にするため。

**Independent Test**: 本を 1 冊登録し、一覧に表示されることを確かめる。

**Acceptance Scenarios**:

1. **Given** 担当者がログインしている, **When** タイトル・著者・ISBN を入れて登録する, **Then** 一覧に本が表示される
2. **Given** 同じ ISBN の本がある, **When** 登録する, **Then** 冊数が 1 増える

### User Story 2 - 本を検索する (Priority: P2)

利用者として、読みたい本があるか探したい。

**Independent Test**: タイトルの一部で検索し、該当する本が出ることを確かめる。

**Acceptance Scenarios**:

1. **Given** 本が登録されている, **When** タイトルの一部で検索する, **Then** 該当する本が一覧に出る

## Requirements

- **FR-001**: 担当者は本を登録できる（タイトル・著者・ISBN）
- **FR-002**: 利用者はタイトル・著者で本を検索できる

## Success Criteria

- **SC-001**: 担当者が 1 冊を 1 分以内に登録できる
