# Implementation Plan: 本の登録

**Branch**: `001-book-register` | **Spec**: [spec.md](spec.md)

## Summary

本の登録と検索を、Web の画面と API で提供する。

## Technical Context

- **Language/Version**: TypeScript 5
- **Primary Dependencies**: Next.js（画面）、Hono（API）
- **Storage**: PostgreSQL
- **Testing**: Vitest

## Project Structure

```text
src/
├── db/          # DB の接続とマイグレーション
├── models/      # Book など
├── api/         # API
└── pages/       # 画面
tests/
```

## Data Model

| エンティティ | 属性 |
|---|---|
| Book | id, title, author, isbn, copies |
