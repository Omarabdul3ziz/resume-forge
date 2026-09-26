# resume-forge manual

## Commands

| Command | What it does |
|---|---|
| `/resume-forge:tailor <job>` | Makes a full application for one job. `<job>` can be a URL, a file, or pasted text. |
| `/resume-forge:tailor` | Same, but asks you for the job first. |
| `/resume-forge:tailor master <role>` | Makes a general resume for a role, not tied to one job. |
| `/resume-forge:tailor <folder> <feedback>` | Revises an application you already made. |
| `/resume-forge:import <sources>` | Adds or updates your facts from a resume PDF, a `.tex` or text file, a LinkedIn export `.zip`, or a GitHub username. |

You rarely need `import`: the first `tailor` runs it for you. Use it later to add a new job or new evidence.

```
/resume-forge:import ~/resume.pdf janedoe          # resume + GitHub evidence
/resume-forge:import ~/Downloads/linkedin.zip      # merge a LinkedIn export
```

Import merges instead of overwriting. If a source disagrees with what you already have (different dates or numbers), it asks you which one is right.

## Your data: `info.json`

All your facts live in `~/resume-forge-data/info.json`. To store them somewhere else, set `$RESUME_FORGE_HOME`. The resume is built only from this file. See [info.example.json](../skills/tailor/info.example.json) for the format.

Each contribution keeps its words and its number apart:

```json
{ "text": "Rewrote order lookups with covering indexes and a Redis cache",
  "metric": "p95 latency from 800ms to 120ms",
  "evidence": "https://github.com/acme/orders/pull/123" }
```

- `text` is what you did. It never contains a number.
- `metric` is the number.
- `evidence` is where someone could verify it: a PR, a dashboard, a release page, or a benchmark.

**A metric without evidence is blocked.** The resume still describes the work, just without the number. To unblock a metric, add its evidence. The report after each run lists the metrics that were left out.

Tip: keep the data folder as a private git repo (`cd ~/resume-forge-data && git init`) so every application you've sent is versioned and backed up.

## Applications

Each job gets a folder: `~/resume-forge-data/applications/<date>-<company>/`.

| File | Purpose |
|---|---|
| `<First>-<Last>-Resume-<Company>.pdf` | The resume to upload |
| `cover.pdf` | The cover letter |
| `resume.txt` | Plain text for forms that make you re-type your resume |
| `keywords.txt` | Each must-have judged match, partial, or gap |
| `review.md` | The hiring manager agent's review |
| `advices.md` | Gap answers, likely interview questions, and stories to prepare |
| `job.md`, `*.tex` | The source job description and the LaTeX sources |

Master resumes go to `~/resume-forge-data/master/<role>/` and skip the cover letter and `advices.md`.

### The FIT score

```
FIT: 79% (8 match, 2 partial, 2 gap of 12 must-haves)
```

Each must-have in the job is judged by meaning, not spelling. RabbitMQ counts as a match for "message queues". GCP is only a partial match for AWS. A partial counts as half. The reasoning for each call is in `keywords.txt`, so you can check it and push back.

### Revising

Keep talking in the same session:

> make it one page · lead with the payments work · drop the tinykv project

To revise later, point `tailor` at the folder:

```
/resume-forge:tailor ~/resume-forge-data/applications/2026-09-26-acme make it one page
```

If a change needs a fact that isn't in `info.json`, it asks you for the fact and saves it first.

## The checks

Every build runs `check.sh`. A resume that fails is fixed before you see it. The checks are:

- Every number must be a metric with evidence.
- No banned words (`banned.txt`), no first person, no em-dashes in bullets.
- Bullets are 2 lines or less, with at most 4 per project.
- The resume is 2 pages or less. The cover letter is 1 page and 300 words or less.
- The PDF text must contain your name, email, phone, the standard headings, and the job's wording for each must-have you match.

To run the checks yourself:

```
skills/tailor/check.sh ~/resume-forge-data/applications/2026-09-26-acme
```

## Customize

| To change | Edit |
|---|---|
| Writing rules | `skills/tailor/rules.md` |
| Banned words | `skills/tailor/banned.txt` |
| Look and layout | `skills/tailor/templates/` |
| What the reviewer looks for | `agents/hiring-manager.md` |

To develop locally, run `claude --plugin-dir .`. Inside this repo, `/tailor` and `/import` also work directly.

## Troubleshooting

**"command not found: tectonic" (or pdftotext, jq).** Install the missing tools:

- Arch: `sudo pacman -S tectonic poppler jq`
- macOS: `brew install tectonic poppler jq`
- Debian/Ubuntu: `sudo apt install poppler-utils jq`, then `curl -fsSL https://drop-sh.fullyjustified.net | sh` for tectonic

**The job page won't load (LinkedIn, login walls).** Paste the job description text instead of the link.

**A number I wanted is missing.** It has no `evidence` in `info.json`. Add a link and run tailor again.

**The fit score seems wrong.** Open `keywords.txt`, see the reasoning, and tell Claude what it missed. If it's a real fact, it gets added to `info.json`.
