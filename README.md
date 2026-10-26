# book-lending-sample

タスク管理のやり方を比べるためのサンプルです。Task の一覧を Markdown（`tasks.md`）に持ち、進み具合を GitHub の Issues と Projects で見る場合に、Issue をどの単位で起こすとよいかを、実物で見比べられるようにしました。題材は架空の「本の貸し出し管理ツール」です（コードはありません）。

- Project：[demo project](https://github.com/users/jun-itagaki-slalom/projects/2)
- 仕様・計画・Task の書式は [GitHub Spec Kit](https://github.com/github/spec-kit) に合わせています

## 構成

```text
specs/
├── 001-book-register/   機能 1：本の登録（ストーリー 2 つ、Task 9 件）
│   ├── spec.md          何を作るか（ユーザーストーリーと受け入れ条件）
│   ├── plan.md          どう作るか（技術・構成・データモデル）
│   └── tasks.md         Task の一覧（T001〜。Phase とストーリーの印 [US1] 付き）
└── 002-lending/         機能 2：貸し出し（ストーリー 2 つ、Task 8 件）
scripts/                 tasks.md から Issue を起こすスクリプト
```

## 見比べる 3 つのやり方

| やり方 | Issue の単位 | ラベル | Issue | 結果 |
|---|---|---|---|---|
| ケース 1 の再現 | Task（タイトルは `T001: …`） | `demo:case1` | #1〜#9（閉じてある） | 機能 1 は 9 件できた。**機能 2 は 8 件すべてが「もうある」と判定され、1 件もできなかった** |
| A：Task ごと（対策あり） | 機能・ストーリー・Task（`F002-T001: …`） | `pattern:A` | #10〜#32（23 件） | 2 つの機能とも、すべての Task の Issue ができた。もう一度動かしても重複しない |
| A'：ストーリーごと | 機能・ストーリー（Task は `tasks.md` だけ） | `pattern:A-prime` | #33〜#38（6 件） | Issue は 6 件。Task の進み具合は `tasks.md` のチェックで見る |

### ケース 1：ID のぶつかり合い

Spec Kit の Issue を起こす拡張（`speckit.github.taskstoissues`）は、Issue を作る前に**リポジトリ全体の Issue のタイトルから `T001` などの ID を探し**、見つかった ID の Issue を作りません。機能は見ません。Task の ID は機能ごとに T001 から振られるため、機能 2 の `T001 Loan モデルとテーブルを作る` は、機能 1 の `T001: プロジェクトの構成を作る` と同じ ID とみなされて飛ばされます。

`scripts/case1-naive-taskstoissues.sh` は、この重複チェックの手順を真似たものです（Spec Kit そのものは動かしていません）。

### A：対策を入れた版

- ID に機能の印を付ける（`F002-T001`）。機能が違えば T001 がぶつからない
- 機能 → ストーリー → Task の親子を sub-issue で作る。ストーリーのない Task（Setup・Foundational・Polish）は機能の直下に置く
- 最後に `tasks.md` と Issue のずれ（Issue にだけある、文言が違う）を一覧で出す
- 後から足した Task は末尾の番号を使い、ほかの ID は振り直さない（`specs/002-lending/tasks.md` の T008。順番は並びで表す）

### A'：ストーリーごと

- Issue は機能とストーリーだけ。Task の ID を Issue に持たないため、ケース 1 のようなぶつかり合いや、番号の振り直しによるずれが起きない
- ストーリーの Issue の本文に、属する Task の ID と `tasks.md` へのリンクを書く
- ストーリーのない Task は、機能の Issue の本文に挙げる

### 依存関係（blocked by）

機能をまたぐ順番の例として、「貸し出しの Loan テーブルは、本の登録の Book モデルの後」を付けました。

- A：#25（F002-T001）は #16（F001-T004）に blocked by
- A'：#36（F002）は #34（F001-US1）に blocked by

## Project での見方

1. [demo project](https://github.com/users/jun-itagaki-slalom/projects/2) を開く
2. フィルターに `label:pattern:A` または `label:pattern:A-prime` と入れる（ビューとして保存すると比べやすい）
3. ビューの設定で **Show hierarchy** を有効にすると、機能 → ストーリー → Task の親子で並ぶ
4. 見比べる点：Issue の数（Sprint・担当・期限を入れる手間）、親子の見え方、Task 単位で担当や Status を持てるか

## 制約

- 個人のリポジトリでは Issue Type（Epic・Story・Task）が使えないため、`type:feature`・`type:story`・`type:task` のラベルで代わりに表しています。Org のリポジトリでは Issue Type を使います
- Sprint（Iteration）・担当・期限・見積は入れていません（人が入れる値のため）
- Spec Kit の拡張は AI エージェントが MCP server で動かすものです。ここでは同じ手順を gh のスクリプトで真似ています

## スクリプトの動かし方

gh CLI でログインした状態で、リポジトリのルートから動かします（Git Bash などの bash）。

```bash
bash scripts/pattern-a-taskstoissues.sh specs/002-lending
```

| スクリプト | やること |
|---|---|
| `scripts/case1-naive-taskstoissues.sh` | ケース 1 の再現（拡張の重複チェックをそのまま真似る） |
| `scripts/pattern-a-taskstoissues.sh` | A：Task ごとに Issue を起こし、ずれを一覧で出す |
| `scripts/pattern-a-prime-storiestoissues.sh` | A'：機能とストーリーの Issue を起こす |
| `scripts/lib.sh` | 共通の関数（`REPO`・`OWNER`・`PROJECT` は環境変数で変えられる） |
