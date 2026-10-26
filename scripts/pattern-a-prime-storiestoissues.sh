#!/usr/bin/env bash
# 選択肢 A'：Issue は機能とストーリーの単位で作り、Task は tasks.md だけに置く。
#   - Task の ID を Issue に持たないため、ケース 1・2 のずれは起きない
#   - Setup・Foundational・Polish の Task は、機能の Issue で扱う
# 何度動かしてもよい（既にある Issue は作らない）。
# 使い方：scripts/pattern-a-prime-storiestoissues.sh specs/002-lending
source "$(dirname "$0")/lib.sh"

dir="${1:?specs/<機能> を指定する}"
fk="$(feature_key "$dir")"
ftitle="$(feature_title "$dir")"
label="pattern:A-prime"
existing="$(list_issues "$label")"

find_issue() { awk -F'\t' -v p="$1: " 'index($3, p) == 1 { print $1, $2; exit }' <<< "$existing"; }

ensure() { # 頭 タイトル 本文 ラベル 親の番号 → 「番号 ID」
  local key="$1" title="$2" body="$3" labels="$4" parent="${5:-}" found out
  found="$(find_issue "$key")"
  if [[ -n "$found" ]]; then echo "$found"; return; fi
  out="$(create_issue "$title" "$body" "$labels")"
  read -r num id url <<< "$out"
  add_to_project "$url"
  [[ -n "$parent" ]] && add_sub_issue "$parent" "$id"
  echo "created #$num  $title" >&2
  echo "$num $id"
}

tasks_link="$(blob_url "$dir/tasks.md")"
spec_link="$(blob_url "$dir/spec.md")"

# ストーリーに属さない Task（Setup・Foundational・Polish）を機能の Issue の本文に挙げる
common="$(parse_tasks "$dir/tasks.md" | awk -F'\t' '$2 == "" { printf "- %s %s（%s）\n", $1, $3, $4 }')"

read -r fnum _ <<< "$(ensure "$fk" "$fk: $ftitle" \
  "機能の Issue。仕様：[spec.md]($spec_link)

### ストーリーに属さない Task（進み具合は [tasks.md]($tasks_link) のチェックで見る）
$common" \
  "type:feature,$label")"

while IFS=$'\t' read -r us name; do
  ids="$(parse_tasks "$dir/tasks.md" | awk -F'\t' -v us="$us" '$2 == us { printf "%s ", $1 }')"
  ensure "$fk-$us" "$fk-$us: $name" \
    "ユーザーストーリーの Issue。

### 受け入れ条件
[spec.md]($spec_link) の User Story ${us#US} を見る（写さない）

### Task
[tasks.md]($tasks_link) の ${ids}（進み具合は tasks.md のチェックで見る）

### 完了条件
- [ ] 上の Task をすべて終え、PR がマージされている" \
    "type:story,$label" "$fnum" > /dev/null
done < <(parse_stories "$dir/tasks.md")

echo "$fk：完了"
