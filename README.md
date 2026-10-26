# book-lending-sample

タスク管理のやり方を確かめるためのサンプルです。Task の一覧を Markdown（`tasks.md`）に持ち、進み具合を GitHub の Issues と Projects で見るときに、Issue をどの単位で作るとよいかを、実物で見られるようにしました。題材は架空の「本の貸し出し管理ツール」です（コードはありません）。

- Project：[demo project](https://github.com/users/jun-itagaki-slalom/projects/2)（推奨のやり方の Issue だけを載せています）
- 仕様・計画・Task の書式は [GitHub Spec Kit](https://github.com/github/spec-kit) に合わせています
- 理解のための参考です。推奨の根拠ではありません

## 推奨のやり方

**Issue は機能とストーリーの単位で作り、Task は原則 `tasks.md` だけに置く。1 つのストーリーを 2 人以上で分けるときだけ、そのストーリーの Task も Issue にする。**

| 何を | どこで持つか |
|---|---|
| ストーリー（何を作るか）と受け入れ条件 | `spec.md`。ストーリーごとに Issue を作り、機能の Issue の sub-issue にする |
| Task の一覧と順序 | `tasks.md`。原則 Issue にしない |
| 担当・Sprint・期限 | ストーリーの Issue（Project のフィールド）。2 人以上で分けるストーリーだけ、Task の Issue |
| 進み具合 | ストーリーの Issue の Status。Task ごとの進み具合は `tasks.md` のチェック |

このサンプルの Issue（ラベル `pattern:A-prime`）：

```text
#33 F001: 本の登録
├── #34 F001-US1: 本を登録する          … 1 人で持つストーリー（Task は tasks.md だけ）
└── #35 F001-US2: 本を検索する
#36 F002: 貸し出し
├── #37 F002-US1: 本を貸し出す          … 2 人で分けるストーリーの例
│   ├── #39 F002-T002: 貸出 API を作る
│   ├── #40 F002-T008: 在庫がないときに貸し出せないようにする
│   └── #41 F002-T003: 貸出画面を作る
└── #38 F002-US2: 本を返却する
```

- Sprint（Iteration）は、Sprint Planning の例として #34・#37 と #37 の Task に入れてあります
- Task の Issue の ID には機能の印を付けます（`F002-T002`）。Task の ID は機能ごとに T001 から振られるため、印がないと機能をまたいでぶつかります（下のケース 1）
- 後から足した Task は末尾の番号を使い、ほかの ID は振り直しません（`specs/002-lending/tasks.md` の T008。順番は並びで表す）
- 機能をまたぐ順番の例として、#36（F002）は #34（F001-US1）に blocked by を付けています

## Project での見方

1. [demo project](https://github.com/users/jun-itagaki-slalom/projects/2) を開く
2. ビューの設定で **Show hierarchy** を有効にすると、機能 → ストーリー → Task の親子で並ぶ
3. **Current iteration** のビューで、Sprint に入れたストーリーと Task を見る

## 比べるために残しているもの

推奨を決める途中で比べたやり方の Issue も、リポジトリに残しています（Project からはアーカイブ済み。Project の Archived items から戻せます）。

| やり方 | ラベル | Issue | 結果 |
|---|---|---|---|
| ケース 1 の再現：Spec Kit の拡張と同じ重複チェック | `demo:case1` | #1〜#9（閉じてある） | 機能 1 は 9 件できた。**機能 2 は 8 件すべてが「もうある」と判定され、1 件もできなかった** |
| すべての Task を Issue にする（選択肢 A） | `pattern:A` | #10〜#32（23 件） | 2 つの機能で 23 件。推奨（9 件）より Issue が多く、全件に Sprint・担当を入れる手間がかかる |

### ケース 1：ID のぶつかり合い

Spec Kit の Issue を起こす拡張（`speckit.github.taskstoissues`）は、Issue を作る前に**リポジトリ全体の Issue のタイトルから `T001` などの ID を探し**、見つかった ID の Issue を作りません。機能は見ません。そのため、機能 2 の `T001 Loan モデルとテーブルを作る` は、機能 1 の `T001: プロジェクトの構成を作る` と同じ ID とみなされて飛ばされます。`scripts/case1-naive-taskstoissues.sh` は、この重複チェックの手順を真似たものです（Spec Kit そのものは動かしていません）。

## 構成

```text
specs/
├── 001-book-register/   機能 1：本の登録（ストーリー 2 つ、Task 9 件）
│   ├── spec.md          何を作るか（ユーザーストーリーと受け入れ条件）
│   ├── plan.md          どう作るか（技術・構成・データモデル）
│   └── tasks.md         Task の一覧（T001〜。Phase とストーリーの印 [US1] 付き）
└── 002-lending/         機能 2：貸し出し（ストーリー 2 つ、Task 8 件）
scripts/                 tasks.md・spec.md から Issue を起こすスクリプト
```

## スクリプトの動かし方

gh CLI でログインした状態で、リポジトリのルートから動かします（Git Bash などの bash）。

```bash
bash scripts/pattern-a-prime-storiestoissues.sh specs/002-lending
```

| スクリプト | やること |
|---|---|
| `scripts/pattern-a-prime-storiestoissues.sh` | 推奨：機能とストーリーの Issue を起こす |
| `scripts/story-task-issues.sh` | 推奨：2 人以上で分けるストーリーの Task を Issue にする（例：`specs/002-lending US1`） |
| `scripts/pattern-a-taskstoissues.sh` | 比較用：すべての Task の Issue を起こし、ずれを一覧で出す（選択肢 A） |
| `scripts/case1-naive-taskstoissues.sh` | 比較用：ケース 1 の再現（拡張の重複チェックをそのまま真似る） |
| `scripts/lib.sh` | 共通の関数（`REPO`・`OWNER`・`PROJECT` は環境変数で変えられる） |

作った直後の Issue は、一覧にすぐ出ないことがあります。同じスクリプトを続けて動かすと重複することがあるため、2 回目は少し時間をおいてください（このサンプルでも #42 が重複し、not planned で閉じました）。

## 制約

- 個人のリポジトリでは Issue Type（Epic・Story・Task）が使えないため、`type:feature`・`type:story`・`type:task` のラベルで代わりに表しています。Org のリポジトリでは Issue Type を使います
- 個人のアカウントのため、担当（Assignees）は入れていません。2 人で分けるストーリーでは、Task の Issue ごとに担当を入れる想定です
- Spec Kit の拡張は AI エージェントが MCP server で動かすものです。ここでは同じ手順を gh のスクリプトで真似ています
