---
name: tailor
description: resume-forge. Generate a job-tailored resume, cover letter, review, and interview prep from a job description. Use when the user runs /tailor or asks to tailor a resume or apply for a job.
argument-hint: <job url | file path | pasted job description>
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/check.sh *) Bash(rm -f *.aux *.log *.out) Bash(tectonic *) Bash(pdftotext *) Bash(pdfinfo *) Bash(cp *) Bash(mkdir *)
---

Tailor an application for: $ARGUMENTS

`S=${CLAUDE_SKILL_DIR}` holds the tool: `rules.md`, `check.sh`, `banned.txt`, `templates/`, `info.example.json`.
Data folder `D` = `$RESUME_FORGE_HOME` if set, else `~/resume-forge-data`. It holds `info.json` and `applications/`. Work there no matter which directory Claude was started in.

Every application lives in one folder with fixed file names:

```
$D/applications/<YYYY-MM-DD>-<company-slug>/
  job.md        job description (source)
  resume.tex    resume.pdf
  cover.tex     cover.pdf
  review.md     hiring-manager review
  advices.md    coverage, gaps, interview prep
```

## Steps

0. **No `$D/info.json`?** Stop and tell the user to run the `import` skill first (`/resume-forge:import <resume.pdf>`).
1. **Get the job description.** URL → WebFetch it. File → read it. Pasted text → use it. If the fetch is blocked or the text looks incomplete (LinkedIn often is), ask the user to paste it. Don't guess.
2. **Create the folder.** Slug = company name lowercased, hyphens (`acme-corp`), date = today. If a folder for the same company exists, ask whether to overwrite it or make a new one. Write the description to `job.md` with the company, role, and URL at the top. Copy `$S/templates/styles.sty` into the folder.
3. **Read the inputs:** `$S/rules.md` (follow it strictly), `info.json`, `$S/templates/resume.tex`, `$S/templates/cover.tex`. Fill the template placeholders (NAME, PHONE, ...) from `info.json` `profile`.
4. **Map before writing.** List the job's must-haves and nice-to-haves, and match each one to `info.json` facts or mark it `GAP`. Keep this for `advices.md`.
5. **Write `resume.tex` and `cover.tex`.**
6. **Build and check:** in the folder, run `tectonic resume.tex && tectonic cover.tex`, then `$S/check.sh <folder>`. Fix every FAIL and run both again, up to 3 rounds. Never get past a failure by adding facts or loosening a number; drop the claim. Respect each metric's `note`.
7. **Review.** Spawn the `hiring-manager` agent (`resume-forge:hiring-manager` when installed as a plugin) with the folder path. It writes `review.md`. Apply its fixes when they're backed by `info.json`, then rebuild and re-check. Ignore suggestions that need facts the user doesn't have. Those go in `advices.md` as gaps.
8. **Write `advices.md`** following `rules.md`.
9. **Clean up** with `rm -f <folder>/*.aux <folder>/*.log <folder>/*.out`.
10. **Report** in a few lines: folder path, page count, check status, the reviewer's verdict, top 3 gaps, and any `info.json` metrics you left out because they had no evidence. Filling in that evidence would make the resume stronger.

Never submit applications or contact anyone. The user sends it.
