#!/usr/bin/env bash
# ケース 1 の再現：Spec Kit の github 拡張（speckit.github.taskstoissues）の重複チェックを、そのまま真似る。
#   1. tasks.md の Task の ID（T001 など）を集める
#   2. リポジトリ全体の Issue のタイトルから \bT\d{3,}\b を探し、見つかった ID は「もうある」とする
#   3. ない ID だけ「T001: <説明>」のタイトルで Issue を作る
# 機能（specs/<機能>/）を見ないため、2 つ目の機能では ID がぶつかって Issue ができない。
# 使い方：scripts/case1-naive-taskstoissues.sh specs/001-book-register
source "$(dirname "$0")/lib.sh"

dir="${1:?specs/<機能> を指定する}"
existing="$(list_issues | cut -f3 | grep -oE '\bT[0-9]{3,}\b' | sort -u || true)"
created=0; skipped=0

while IFS=$'\t' read -r id story desc phase; do
  if grep -qx "$id" <<< "$existing"; then
    echo "$id already has an issue, skipping（$desc）"
    skipped=$((skipped + 1))
  else
    out="$(create_issue "$id: $desc" "ケース 1 の再現で作った Issue。元の Task：\`$dir/tasks.md\` の $id" "demo:case1")"
    echo "created #${out%% *}  $id: $desc"
    created=$((created + 1))
  fi
done < <(parse_tasks "$dir/tasks.md")

echo "---"
echo "$dir：作った $created 件、飛ばした $skipped 件"
