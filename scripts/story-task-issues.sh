#!/usr/bin/env bash
# 推奨（A'）の補い：2 人以上で分けるストーリーだけ、そのストーリーの Task を Issue にする。
#   - pattern-a-prime-storiestoissues.sh で作ったストーリーの Issue の sub-issue にする
#   - ID に機能の印を付ける（F002-T002）→ 機能が違えば T002 がぶつからない
#   - 探す範囲を pattern:A-prime のラベルが付いた Issue に限る
#   - そのストーリーの Task（[USn] が付いた Task）をすべて Issue にする
# 何度動かしてもよい（既にある Issue は作らない）。
# 注意：作った直後の Issue は、一覧（API）にすぐ出ないことがある。続けて動かすと重複することがあるため、
#       2 回目は少し時間をおく（このサンプルでも #42 が重複し、not planned で閉じた）。
# 使い方：scripts/story-task-issues.sh specs/002-lending US1
source "$(dirname "$0")/lib.sh"

dir="${1:?specs/<機能> を指定する}"
us="${2:?ストーリーの番号（US1 など）を指定する}"
fk="$(feature_key "$dir")"
label="pattern:A-prime"
existing="$(list_issues "$label")"
find_issue() { awk -F'\t' -v p="$1: " 'index($3, p) == 1 { print $1, $2; exit }' <<< "$existing"; }

read -r snum _ <<< "$(find_issue "$fk-$us")"
[[ -n "${snum:-}" ]] || { echo "$fk-$us のストーリーの Issue がない。先に pattern-a-prime-storiestoissues.sh を動かす" >&2; exit 1; }

tasks_link="$(blob_url "$dir/tasks.md")"
created=0
while IFS=$'\t' read -r id story desc phase; do
  [[ "$story" == "$us" ]] || continue
  if [[ -n "$(find_issue "$fk-$id")" ]]; then echo "$fk-$id already has an issue, skipping"; continue; fi
  body="### やること
$desc

### 成果物
（tasks.md の行に書いたファイル）

### 完了条件
- [ ] [tasks.md]($tasks_link) の $id（$phase）を終え、PR がマージされている

（2 人以上で分けるストーリー #$snum の Task。担当と Status はこの Issue で持つ）"
  read -r num iid url <<< "$(create_issue "$fk-$id: $desc" "$body" "type:task,$label")"
  add_to_project "$url"
  add_sub_issue "$snum" "$iid"
  echo "created #$num  $fk-$id: $desc（#$snum の sub-issue）"
  created=$((created + 1))
done < <(parse_tasks "$dir/tasks.md")
echo "$fk-$us：作った $created 件"
