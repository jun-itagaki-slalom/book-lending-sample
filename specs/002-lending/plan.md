# Implementation Plan: 貸し出し

**Branch**: `002-lending` | **Spec**: [spec.md](spec.md)

## Summary

本の貸し出しと返却を、Web の画面と API で提供する。001-book-register の Book を使う。

## Technical Context

- **Language/Version**: TypeScript 5
- **Primary Dependencies**: Next.js（画面）、Hono（API）
- **Storage**: PostgreSQL
- **Testing**: Vitest

## Data Model

| エンティティ | 属性 |
|---|---|
| Loan | id, bookId, userId, lentAt, dueAt, returnedAt |
