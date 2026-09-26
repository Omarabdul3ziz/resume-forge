#!/usr/bin/env bash
# Usage: check.sh <data>/applications/<date>-<company>   (info.json is read from <data>/)
# Fails if the resume/cover break the hard rules in rules.md.
set -uo pipefail

dir=${1:?usage: ./check.sh <application dir>}
here=$(cd "$(dirname "$0")" && pwd)
info=${INFO:-$dir/../../info.json}
[[ -f $info ]] || { echo "FAIL: $info not found"; exit 1; }
resume=$dir/resume.tex
cover=$dir/cover.tex
fail=0
err() { echo "FAIL: $*"; fail=1; }
warn() { echo "WARN: $*"; }

for f in "$resume" "$cover" "$dir/resume.pdf" "$dir/cover.pdf" "$dir/job.md"; do
  [[ -f $f ]] || err "missing $f"
done
((fail)) && exit 1

# prose = resume bullets + cover letter paragraphs (LaTeX commands skipped)
bullets=$(grep -E '^\s*\\item ' "$resume")
prose=$(printf '%s\n' "$bullets"; grep -vE '^\s*(\\|%|$)' "$cover")

# 1. banned words
while read -r w; do
  [[ -z $w || $w == \#* ]] && continue
  hits=$(grep -inwF -- "$w" <<<"$prose")
  [[ -n $hits ]] && err "banned phrase '$w': $(head -1 <<<"$hits" | cut -c1-100)"
done <"$here/banned.txt"

# 2. no em-dashes inside bullets, max 2 in the cover letter
n=$(grep -cE -- '---|—' <<<"$bullets")
((n > 0)) && err "$n bullet(s) contain an em-dash"
n=$(grep -oE -- '---|—' "$cover" | wc -l)
((n > 2)) && err "cover letter has $n em-dashes (max 2)"

# 3. bullet length and count per project
while IFS= read -r b; do
  len=$(sed -E 's/\\[a-zA-Z]+(\{\})?//g; s/[{}]//g; s/^\s*//' <<<"$b" | wc -c)
  ((len > 230)) && err "bullet over 2 lines ($len chars): $(cut -c1-80 <<<"$b" | sed 's/^\s*//')..."
done <<<"$bullets"
awk '/\\(side)?project\{/ { if (n > 4) print name; match($0, /project\{[^}]*/); name = substr($0, RSTART + 8, RLENGTH - 8); n = 0 }
     /^\s*\\item / { n++ }
     END { if (n > 4) print name }' "$resume" | while read -r p; do echo "FAIL: project '$p' has more than 4 bullets"; done | grep . && fail=1

# 4. every number in the prose must come from a verified metric (or dates/tech names) in info.json
allowed=$(jq -r '[del(.. | objects | select(has("metric") and (.evidence // "") == "") | .metric)
  | del(.. | objects | .note?, .pr?, ._rules?) | .. | strings, numbers] | map(tostring) | .[]' "$info" \
  | grep -oP '(?<![A-Za-z0-9.])[0-9]+(?:[.,][0-9]+)*[x×%+]?' | tr -d , | sed 's/×/x/' | sort -u)
for num in $(grep -oP '(?<![A-Za-z0-9.])[0-9]+(?:[.,][0-9]+)*[x×%+]?' <<<"$prose" | tr -d , | sed 's/×/x/' | sort -u); do
  grep -qx "$num" <<<"$allowed" || err "number '$num' is not a verified metric in info.json: $(tr -d , <<<"$prose" | sed 's/×/x/g' | grep -m1 -- "$num" | sed 's/^\s*//' | cut -c1-90)"
done

# 5. page counts
p=$(pdfinfo "$dir/resume.pdf" | awk '/^Pages:/ {print $2}')
((p > 2)) && err "resume is $p pages (max 2)"
((p == 2)) && [[ $(pdftotext -f 2 -l 2 "$dir/resume.pdf" - | wc -w) -lt 80 ]] && warn "page 2 is nearly empty; cut to 1 page or fill it"
p=$(pdfinfo "$dir/cover.pdf" | awk '/^Pages:/ {print $2}')
((p > 1)) && err "cover letter is $p pages (max 1)"
n=$(grep -vE '^\s*(\\|%|$)' "$cover" | wc -w)
((n > 300)) && err "cover letter is $n words (max 300)"

((fail)) && exit 1
echo "OK: all checks passed"
