---
name: tailor
description: resume-forge. Generate a job-tailored resume, cover letter, review, and interview prep from a job description. Use when the user runs /tailor, asks to tailor a resume or apply for a job, or gives feedback on an application it made.
argument-hint: [job url | file path | pasted job description> | master <role> | <application folder> <feedback>]
allowed-tools: Bash(command -v *) Bash(${CLAUDE_SKILL_DIR}/check.sh *) Bash(rm -f *.aux *.log *.out) Bash(tectonic *) Bash(pdftotext *) Bash(pdfinfo *) Bash(cp *) Bash(mkdir *)
---

Tailor an application for: $ARGUMENTS

`S=${CLAUDE_SKILL_DIR}` holds the tool: `rules.md`, `check.sh`, `banned.txt`, `templates/`, `info.example.json`.
Data folder `D` = `$RESUME_FORGE_HOME` if set, else `~/resume-forge-data`. It holds `info.json` and `applications/`. Work there no matter which directory Claude was started in.

Every application lives in one folder with fixed file names:

```
$D/applications/<YYYY-MM-DD>-<company-slug>/
  job.md        job description (source)
  keywords.txt  each must-have judged match / partial / gap, gives the FIT score
  resume.tex    resume.pdf
  cover.tex     cover.pdf
  review.md     hiring-manager review
  advices.md    gaps, interview prep
  <First>-<Last>-Resume-<Company>.pdf   copy of resume.pdf to upload
  resume.txt    plain text, for forms that make you re-type it
```

## Steps

0. **Setup, only when needed:**
   - Run `command -v tectonic pdftotext pdfinfo jq`. If any is missing, stop and give the one install command for the user's OS: Arch `sudo pacman -S tectonic poppler jq`, macOS `brew install tectonic poppler jq`, Debian/Ubuntu `sudo apt install poppler-utils jq` plus `curl -fsSL https://drop-sh.fullyjustified.net | sh` for tectonic.
   - No `$D/info.json`? Don't stop. Ask for their current resume (a PDF path or pasted text) and, optionally, their GitHub username, then follow `$S/../import/SKILL.md` to build it. Continue with the job after.
1. **Get the job description.** No argument → ask "Paste the job link or description." URL → WebFetch it. File → read it. Pasted text → use it. If the fetch is blocked or the text looks incomplete (LinkedIn often is), ask the user to paste it. Don't guess.
2. **Create the folder.** Slug = company name lowercased, hyphens (`acme-corp`), date = today. If a folder for the same company exists, ask whether to overwrite it or make a new one. Write the description to `job.md` with the company, role, and URL at the top. Copy `$S/templates/styles.sty` into the folder.
3. **Read the inputs:** `$S/rules.md` (follow it strictly), `info.json`, `$S/templates/resume.tex`, `$S/templates/cover.tex`. Fill the template placeholders (NAME, PHONE, ...) from `info.json` `profile`.
4. **Map before writing.** Judge each of the job's must-haves against `info.json` and write `keywords.txt` (see rules.md).
5. **Write `resume.tex` and `cover.tex`.**
6. **Build and check:** in the folder, run `tectonic resume.tex && tectonic cover.tex`, then `$S/check.sh <folder>`. Fix every FAIL and run both again, up to 3 rounds. Never get past a failure by adding facts or loosening a number; drop the claim. Respect each metric's `note`.
7. **Review.** Spawn the `hiring-manager` agent (`resume-forge:hiring-manager` when installed as a plugin) with the folder path. It writes `review.md`. Apply its fixes when they're backed by `info.json`, then rebuild and re-check. Ignore suggestions that need facts the user doesn't have. Those go in `advices.md` as gaps.
8. **Write `advices.md`** following `rules.md`.
9. **Clean up** with `rm -f <folder>/*.aux <folder>/*.log <folder>/*.out`, then `cp resume.pdf <First>-<Last>-Resume-<Company>.pdf` (recruiters see the uploaded file name) and `pdftotext -layout resume.pdf resume.txt`.
10. **Report**, short, most useful first:
    ```
    Ready: <path to the upload copy>  (+ cover.pdf)
    FIT: <score line from check.sh>
    Reviewer: <one-line verdict>
    Top gaps: <up to 3>  → answers in advices.md
    ```
    Then, only if relevant: page count, remaining WARNs, and `info.json` metrics left out for missing evidence (adding it would make the resume stronger). End with: "Want changes? Just tell me (e.g. \"make it one page\")."

## Master resume

`master <role>` (e.g. `master backend engineer`) makes one general resume for that role, not for a job: for job fairs, referrals, and recruiters who reach out first. Same steps, except:

- Skip step 1. Folder `$D/master/<role-slug>/`, replace it if it exists.
- `job.md` starts with `Master resume: <role>` and lists the must-haves most postings for this role ask for. `keywords.txt` judges those, so FIT shows how you fit the role in general.
- No cover letter and no `advices.md`. The review still runs.
- Upload copy is `<First>-<Last>-Resume.pdf`.

Rerun it when `info.json` changes.

## Revise

When the argument is an existing application or master folder, or the user gives feedback after a `/tailor` in this session ("one page", "lead with the payments work", "drop tinykv"), revise that folder instead of starting a new one:

1. Read `$S/rules.md`, `info.json`, and the folder's `job.md`, `keywords.txt`, `resume.tex`, `cover.tex`.
2. Apply the feedback. The rules still hold: if it needs a fact that's not in `info.json`, ask the user for it, add it to `info.json` (numbers need evidence), then use it. If it closes a gap, update its line in `keywords.txt`.
3. Build and check (step 6). Rerun the review (step 7) only if the user asks.
4. Update `advices.md` if coverage or gaps changed, clean up and refresh the upload copy (step 9), and report what changed plus the new `FIT` score.

Never submit applications or contact anyone. The user sends it.
