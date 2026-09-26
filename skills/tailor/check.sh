#!/usr/bin/env bash
# Usage: check.sh <data>/applications/<date>-<company>   (info.json is read from <data>/)
# Fails if the resume/cover break the hard rules in rules.md, or an ATS parser would miss contact info, headings, or keywords.
set -uo pipefail

dir=${1:?usage: ./check.sh <application dir>}
here=$(cd "$(dirname "$0")" && pwd)
info=${INFO:-$dir/../../info.json}
[[ -f $dir/info.json ]] && info=${INFO:-$dir/info.json}
[[ -f $info ]] || { echo "FAIL: $info not found"; exit 1; }
resume=$dir/resume.tex
cover=$dir/cover.tex
fail=0
err() { echo "FAIL: $*"; fail=1; }
warn() { echo "WARN: $*"; }

# a master resume (no job) has no cover letter
[[ -f $cover ]] || { grep -q '^Master resume' "$dir/job.md" 2>/dev/null && cover=/dev/null; }
for f in "$resume" "$cover" "$dir/resume.pdf" "$dir/job.md" "$dir/keywords.txt"; do
  [[ -e $f ]] || err "missing $f"
done
[[ $cover == /dev/null || -f $dir/cover.pdf ]] || err "missing $dir/cover.pdf"
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

# 3. weak or first-person bullets
while IFS= read -r b; do
  t=$(sed -E 's/^\s*\\item\s*//' <<<"$b")
  grep -qiE '\b(responsible for|worked on|helped (with|to)|duties included|involved in)\b' <<<"$t" && err "weak phrase, say what you did: $(cut -c1-80 <<<"$t")"
  grep -qP '(?<![\w/])I(?![\w/])|\b([Mm]y|[Ww]e|[Oo]ur)\b' <<<"$t" && err "first person in a bullet: $(cut -c1-80 <<<"$t")"
  grep -qE '^[A-Z][a-z]+(ing|s)\b' <<<"$t" && warn "bullet should start with a past-tense verb (Built, not Builds/Building): $(cut -c1-80 <<<"$t")"
done <<<"$bullets"

# 4. bullet length and count per project
while IFS= read -r b; do
  len=$(sed -E 's/\\[a-zA-Z]+(\{\})?//g; s/[{}]//g; s/^\s*//' <<<"$b" | wc -c)
  ((len > 230)) && err "bullet over 2 lines ($len chars): $(cut -c1-80 <<<"$b" | sed 's/^\s*//')..."
done <<<"$bullets"
awk '/\\(side)?project\{/ { if (n > 4) print name; match($0, /project\{[^}]*/); name = substr($0, RSTART + 8, RLENGTH - 8); n = 0 }
     /^\s*\\item / { n++ }
     END { if (n > 4) print name }' "$resume" | while read -r p; do echo "FAIL: project '$p' has more than 4 bullets"; done | grep . && fail=1

# 5. every number in the prose must come from a verified metric (or dates/tech names) in info.json
allowed=$(jq -r '[del(.. | objects | select(has("metric") and (.evidence // "") == "") | .metric)
  | del(.. | objects | .note?, .pr?, ._rules?) | .. | strings, numbers] | map(tostring) | .[]' "$info" \
  | grep -oP '(?<![A-Za-z0-9.])[0-9]+(?:[.,][0-9]+)*[x×%+]?' | tr -d , | sed 's/×/x/' | sort -u)
for num in $(grep -oP '(?<![A-Za-z0-9.])[0-9]+(?:[.,][0-9]+)*[x×%+]?' <<<"$prose" | tr -d , | sed 's/×/x/' | sort -u); do
  grep -qx "$num" <<<"$allowed" || err "number '$num' is not a verified metric in info.json: $(tr -d , <<<"$prose" | sed 's/×/x/g' | grep -m1 -- "$num" | sed 's/^\s*//' | cut -c1-90)"
done

# 6. page counts
p=$(pdfinfo "$dir/resume.pdf" | awk '/^Pages:/ {print $2}')
((p > 2)) && err "resume is $p pages (max 2)"
((p == 2)) && [[ $(pdftotext -f 2 -l 2 "$dir/resume.pdf" - | wc -w) -lt 80 ]] && warn "page 2 is nearly empty; cut to 1 page or fill it"
if [[ $cover != /dev/null ]]; then
  p=$(pdfinfo "$dir/cover.pdf" | awk '/^Pages:/ {print $2}')
  ((p > 1)) && err "cover letter is $p pages (max 1)"
fi
n=$(grep -vE '^\s*(\\|%|$)' "$cover" | wc -w)
((n > 300)) && err "cover letter is $n words (max 300)"

# 7. ATS parse: what a parser extracts from the PDF (joined into one line so terms split across lines still match)
text=$(pdftotext "$dir/resume.pdf" - | tr -s '[:space:]' ' ')
for field in name email; do
  v=$(jq -r ".profile.$field // empty" "$info")
  [[ -n $v ]] && ! grep -qiF -- "$v" <<<"$text" && err "resume PDF text is missing the $field '$v'"
done
phone=$(jq -r '.profile.phone // empty' "$info" | tr -cd 0-9)
[[ -n $phone ]] && ! tr -cd 0-9 <<<"$text" | grep -qF "$phone" && err "resume PDF text is missing the phone number"
for h in Experience Skills Education; do
  grep -qiw "$h" <<<"$text" || err "resume PDF text is missing the '$h' heading"
done

# 8. fit: keywords.txt holds the AI's judgment of each must-have ("match|partial|gap: term -- note").
#    Matched terms (except ones with numbers, like "5+ years") must also appear verbatim in the PDF text, since ATS search is literal.
m=0 part=() gaps=()
while IFS= read -r line; do
  [[ -z $line || $line == \#* ]] && continue
  kind=${line%%:*} term=${line#*:} term=${term%% -- *} term=$(sed 's/^\s*//; s/\s*$//' <<<"$term")
  case ${kind,,} in
    match) ((m++)); [[ $term =~ [0-9] ]] || grep -qiF -- "$term" <<<"$text" || err "matched must-have '$term' is not in the resume PDF text (use the job's wording)" ;;
    partial) part+=("$term") ;;
    gap) gaps+=("$term") ;;
    *) err "keywords.txt: bad line '$line' (want match:, partial:, or gap:)" ;;
  esac
done <"$dir/keywords.txt"
total=$((m + ${#part[@]} + ${#gaps[@]}))
((total)) && echo "FIT: $(((200 * m + 100 * ${#part[@]}) / (2 * total)))% ($m match, ${#part[@]} partial, ${#gaps[@]} gap of $total must-haves)"
((${#part[@]})) && echo "PARTIAL: $(printf '%s, ' "${part[@]}" | sed 's/, $//')"
((${#gaps[@]})) && echo "GAPS: $(printf '%s, ' "${gaps[@]}" | sed 's/, $//')"

((fail)) && exit 1
echo "OK: all checks passed"
