---
name: import
description: resume-forge. Build or update info.json from an existing resume (PDF, .tex, text), a LinkedIn export, or GitHub. Use when the user runs /import or wants to set up or refresh their resume data.
argument-hint: [resume.pdf | file | linkedin.zip | github-username] ...
allowed-tools: Bash(pdftotext *) Bash(gh *) Bash(jq *) Bash(mkdir *) Bash(unzip *)
---

Import resume data from: $ARGUMENTS

Data folder: `$RESUME_FORGE_HOME` if set, else `~/resume-forge-data`. The target is `<data>/info.json`, in the format of `${CLAUDE_SKILL_DIR}/../tailor/info.example.json`.

If the data folder doesn't exist, create it (`mkdir -p <data>/applications`) and continue. At the end, add one tip: keep it as a private git repo for backup (`cd <data> && git init`, or `gh repo create resume-forge-data --private`).

## Steps

1. **Read the sources.** No argument → ask for their resume (PDF path or pasted text) and, optionally, their GitHub username. PDF → `pdftotext -layout <file> -`. `.tex`/text → read it. A LinkedIn data export (`.zip`) → `unzip -o <zip> -d <tmp>` and read `Profile.csv`, `Positions.csv`, `Education.csv`, `Skills.csv`. A GitHub username → `gh` (see step 5). Several sources can be combined.
2. **Merge, don't overwrite.** If `info.json` exists, add only what's new. When a source contradicts `info.json` (different dates, numbers, titles), don't pick one yourself. List every conflict and ask the user.
3. **Dates and location.** Every job and degree needs `Mon YYYY - Mon YYYY` (or `- present`), and `profile.location` needs a city and country: ATS parsers use them to compute experience and filter by location. Ask the user for any that are missing.
4. **Split facts from numbers.** Write each contribution as plain `text` with no digits. Any number (%, x, counts, time saved) goes in `metric`, with `evidence` left empty. Keep the user's wording. Don't polish it or add scope.
5. **Find evidence.** For public work, use `gh` to verify numbers: release/tag counts, merged PR counts (`gh api search/issues -f q='author:<user> org:<org> is:pr'`), and links to the PR behind each claim (put them in a `pr` field). If the real number differs from the claim, use the real one. If a claim can't be verified, leave `evidence` empty and add a `note` saying why.
6. **Ask about the rest.** Show the user the metrics that still have empty evidence, and ask where each can be verified (dashboard, benchmark, ticket). If they can't say, it stays blocked. `/resume-forge:tailor` won't use it.
7. **Save** `info.json` and check that it's valid JSON (`jq empty`). Report what you added, the conflicts you asked about, and which metrics are verified vs blocked.
