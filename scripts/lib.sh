#!/usr/bin/env bash
# 3 つのスクリプトで共通に使う関数。
set -euo pipefail

REPO="${REPO:-jun-itagaki-slalom/book-lending-sample}"
OWNER="${OWNER:-jun-itagaki-slalom}"
PROJECT="${PROJECT:-2}"
BRANCH="${BRANCH:-main}"

# tasks.md を 1 行 1 Task の TSV にする：ID<TAB>Story（なければ -）<TAB>説明<TAB>Phase の見出し
parse_tasks() {
  local file="$1" phase="" line id rest story
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^##\ (Phase.*)$ ]]; then phase="${BASH_REMATCH[1]}"; continue; fi
    if [[ "$line" =~ ^-\ \[[\ xX]\]\ (T[0-9]{3,})\ (.*)$ ]]; then
      id="${BASH_REMATCH[1]}"; rest="${BASH_REMATCH[2]}"; story="-"
      rest="${rest#\[P\] }"
      if [[ "$rest" =~ ^\[(US[0-9]+)\]\ (.*)$ ]]; then story="${BASH_REMATCH[1]}"; rest="${BASH_REMATCH[2]}"; fi
      printf '%s\t%s\t%s\t%s\n' "$id" "$story" "$rest" "$phase"
    fi
  done < "$file"
}

# tasks.md のストーリーの見出しを TSV にする：US番号<TAB>ストーリー名
parse_stories() {
  local file="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^##\ Phase\ [0-9]+:\ User\ Story\ ([0-9]+)\ -\ (.*)\ \(Priority ]]; then
      printf 'US%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    fi
  done < "$file"
}

# specs/002-lending → F002
feature_key() { local base; base="$(basename "$1")"; echo "F${base%%-*}"; }

# spec.md の 1 行目「# Feature Specification: 貸し出し」→ 貸し出し
feature_title() { head -n 1 "$1/spec.md" | tr -d '\r' | sed 's/^# Feature Specification: //'; }

# リポジトリ上のファイルへのリンク
blob_url() { echo "https://github.com/$REPO/blob/$BRANCH/$1"; }

# Issue を作り「番号 ID URL」を返す。ラベルはカンマ区切り
create_issue() {
  local title="$1" body="$2" labels="$3" l
  local args=(-f "title=$title" -f "body=$body")
  IFS=, read -ra ls <<< "$labels"
  for l in "${ls[@]}"; do args+=(-f "labels[]=$l"); done
  gh api "repos/$REPO/issues" "${args[@]}" --jq '"\(.number) \(.id) \(.html_url)"'
}

# Issue の一覧（PR を除く）を「番号<TAB>ID<TAB>タイトル」で返す。ラベルで絞れる
list_issues() {
  local label="${1:-}" q="state=all&per_page=100"
  [[ -n "$label" ]] && q="$q&labels=$label"
  gh api "repos/$REPO/issues?$q" --paginate \
    --jq '.[] | select(.pull_request | not) | "\(.number)\t\(.id)\t\(.title)"'
}

add_sub_issue() { gh api "repos/$REPO/issues/$1/sub_issues" -F "sub_issue_id=$2" --silent; }
add_to_project() { gh project item-add "$PROJECT" --owner "$OWNER" --url "$1" >/dev/null; }
# $1 の Issue（番号）が $2 の Issue（ID）に blocked by される
add_blocked_by() { gh api "repos/$REPO/issues/$1/dependencies/blocked_by" -F "issue_id=$2" --silent; }
