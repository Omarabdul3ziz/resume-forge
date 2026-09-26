# resume-forge

A Claude Code plugin that writes a job-tailored resume and cover letter in LaTeX, using only facts you've verified.

- Every number on the resume must come from your `info.json` with a link to evidence (a PR, a release page, a dashboard). `check.sh` blocks the build otherwise.
- `check.sh` also blocks banned AI words, em-dashes in bullets, bullets over 2 lines, and resumes over 2 pages.
- ATS-readable: `check.sh` reads the PDF the way a parser does and fails if your contact info, the standard headings, or the job's wording for a must-have you have is missing.
- Plain bullets: no "responsible for", no "I", past-tense verbs.
- A separate "hiring manager" agent reviews the PDF against the job description, seeing only what a real reviewer would see.

It's a resume tailor, nothing more. It is not a job tracker and it never applies for you: you read what it wrote and you send it.

![sample resume](docs/resume.png)

A full sample application for a fake candidate is in [docs/sample](docs/sample). Check it with `INFO=skills/tailor/info.example.json skills/tailor/check.sh docs/sample`.

## Install

Requires [Claude Code](https://claude.com/claude-code), `tectonic`, `poppler` (pdftotext/pdfinfo), and `jq`.

```
/plugin marketplace add Omarabdul3ziz/resume-forge
/plugin install resume-forge@resume-forge
```

## Use

```
/resume-forge:import ~/resume.pdf your-github-username   # once: builds info.json, finds evidence on GitHub
/resume-forge:tailor https://company.com/jobs/123         # per job
/resume-forge:tailor master backend engineer              # a general resume for a role, no job needed
```

The report ends with a fit score, like `FIT: 79% (8 match, 2 partial, 2 gap of 12 must-haves)`. The AI judges each must-have by meaning against your `info.json` (RabbitMQ counts for "message queues"; GCP is only partial for AWS) and writes its reasoning in `keywords.txt`, so you can check it.

Not happy with it? Keep talking in the same session ("make it one page", "lead with the payments work") and it revises the same folder. Later, `/resume-forge:tailor ~/resume-forge-data/applications/2026-09-26-acme make it one page`.

Your data stays out of the plugin, in `~/resume-forge-data/` (or `$RESUME_FORGE_HOME`). Keep it as a **private** repo so `info.json` and everything you sent are versioned and backed up:

```
gh repo create resume-forge-data --private --clone   # run in ~
```

```
~/resume-forge-data/
  info.json                      your facts + evidence
  applications/2026-09-26-acme/  job.md  keywords.txt  resume.tex/pdf  cover.tex/pdf  review.md  advices.md
                                 Jane-Doe-Resume-Acme.pdf (the copy you upload)  resume.txt (for re-type forms)
  master/backend-engineer/       the general resume for that role
```

`advices.md` has honest answers for your gaps, likely interview questions, and stories to prepare.

## Layout

```
skills/tailor/      SKILL.md, rules.md, banned.txt, check.sh, templates/, info.example.json
skills/import/      SKILL.md
agents/             hiring-manager.md
.claude-plugin/     plugin manifest
```

Edit `rules.md` and `banned.txt` to change the writing rules, or `templates/` to change the look.

Develop locally with `claude --plugin-dir .`. Inside this repo `/tailor` and `/import` also work directly through the `.claude/` symlinks.

## License

MIT
