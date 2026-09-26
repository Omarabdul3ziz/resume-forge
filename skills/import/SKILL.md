---
name: import
description: resume-forge. Build or update info.json from an existing resume (PDF, .tex, text), a LinkedIn export, or GitHub. Use when the user runs /import or wants to set up or refresh their resume data.
argument-hint: <resume.pdf | file | github-username> ...
allowed-tools: Bash(pdftotext *) Bash(gh *) Bash(jq *) Bash(mkdir *)
---

Import resume data from: $ARGUMENTS

Data folder: `$RESUME_FORGE_HOME` if set, else `~/resume-forge-data`. The target is `<data>/info.json`, in the format of `${CLAUDE_SKILL_DIR}/../tailor/info.example.json`.

If the data folder doesn't exist, suggest keeping it as a private repo: `gh repo create resume-forge-data --private --clone` (run in `~`), or just `mkdir -p ~/resume-forge-data/applications`. Then continue.

## Steps

1. **Read the sources.** PDF → `pdftotext -layout <file> -`. `.tex`/text → read it. A GitHub username → `gh` (see step 4). Several sources can be combined.
2. **Merge, don't overwrite.** If `info.json` exists, add only what's new. When a source contradicts `info.json` (different dates, numbers, titles), don't pick one yourself. List every conflict and ask the user.
3. **Split facts from numbers.** Write each contribution as plain `text` with no digits. Any number (%, x, counts, time saved) goes in `metric`, with `evidence` left empty. Keep the user's wording. Don't polish it or add scope.
4. **Find evidence.** For public work, use `gh` to verify numbers: release/tag counts, merged PR counts (`gh api search/issues -f q='author:<user> org:<org> is:pr'`), and links to the PR behind each claim (put them in a `pr` field). If the real number differs from the claim, use the real one. If a claim can't be verified, leave `evidence` empty and add a `note` saying why.
5. **Ask about the rest.** Show the user the metrics that still have empty evidence, and ask where each can be verified (dashboard, benchmark, ticket). If they can't say, it stays blocked. `/resume-forge:tailor` won't use it.
6. **Save** `info.json` and check that it's valid JSON (`jq empty`). Report what you added, the conflicts you asked about, and which metrics are verified vs blocked.
