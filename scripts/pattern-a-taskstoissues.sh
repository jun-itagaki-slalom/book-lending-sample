#!/usr/bin/env bash
# 選択肢 A（ケース 1・2 の対策を入れた版）：Task ごとに Issue を起こす。
#   - ID に機能の印を付ける（F002-T001）→ 機能が違えば T001 がぶつからない
#   - 探す範囲を pattern:A のラベルが付いた Issue に限る
#   - 機能 → ストーリー → Task の親子を sub-issue で作る（ストーリーのない Task は機能の直下）
#   - 最後に tasks.md と Issue のずれを一覧で出す
# 何度動かしてもよい（既にある Issue は作らない）。
# 使い方：scripts/pattern-a-taskstoissues.sh specs/002-lending
source "$(dirname "$0")/lib.sh"

dir="${1:?specs/<機能> を指定する}"
fk="$(feature_key "$dir")"
ftitle="$(feature_title "$dir")"
label="pattern:A"
existing="$(list_issues "$label")"

# タイトルの頭（F002: / F002-US1: / F002-T001:）で既にある Issue を探し「番号 ID」を返す
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

read -r fnum _ <<< "$(ensure "$fk" "$fk: $ftitle" \
  "機能の Issue。仕様：[spec.md]($spec_link)、Task の一覧：[tasks.md]($tasks_link)" \
  "type:feature,$label")"

declare -A story_num
while IFS=$'\t' read -r us name; do
  read -r snum _ <<< "$(ensure "$fk-$us" "$fk-$us: $name" \
    "ユーザーストーリーの Issue。受け入れ条件は [spec.md]($spec_link) の User Story ${us#US} を見る（写さない）" \
    "type:story,$label" "$fnum")"
  story_num[$us]="$snum"
done < <(parse_stories "$dir/tasks.md")

md_ids=()
while IFS=$'\t' read -r id story desc phase; do
  md_ids+=("$fk-$id")
  parent="$fnum"; [[ -n "$story" ]] && parent="${story_num[$story]}"
  body="### やること
$desc

### 成果物
（tasks.md の行に書いたファイル）

### 完了条件
- [ ] [tasks.md]($tasks_link) の $id（$phase）を終え、PR がマージされている"
  ensure "$fk-$id" "$fk-$id: $desc" "$body" "type:task,$label" "$parent" > /dev/null
done < <(parse_tasks "$dir/tasks.md")

# ずれの一覧：Issue にだけある ID と、タイトルが tasks.md と違うもの
echo "--- ずれの一覧（$fk）"
existing="$(list_issues "$label")"
drift=0
while IFS=$'\t' read -r num _ title; do
  [[ "$title" =~ ^($fk-T[0-9]{3,}):\ (.*)$ ]] || continue
  key="${BASH_REMATCH[1]}"; t="${BASH_REMATCH[2]}"
  if [[ ! " ${md_ids[*]} " =~ " $key " ]]; then
    echo "Issue にだけある：#$num $title"; drift=$((drift + 1)); continue
  fi
  md_desc="$(parse_tasks "$dir/tasks.md" | awk -F'\t' -v id="${key#$fk-}" '$1 == id { print $3 }')"
  if [[ "$md_desc" != "$t" ]]; then
    echo "文言が違う：#$num「$t」→ tasks.md「$md_desc」"; drift=$((drift + 1))
  fi
done <<< "$existing"
echo "ずれ：$drift 件"
