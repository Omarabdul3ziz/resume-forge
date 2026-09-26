# resume-forge

A Claude Code plugin that writes a job-tailored resume and cover letter in LaTeX, using only facts you've verified.

- Every number on the resume must come from your `info.json` with a link to evidence (a PR, a release page, a dashboard). `check.sh` blocks the build otherwise.
- `check.sh` also blocks banned AI words, em-dashes in bullets, bullets over 2 lines, and resumes over 2 pages.
- A separate "hiring manager" agent reviews the PDF against the job description, seeing only what a real reviewer would see.

![sample resume](docs/resume.png)

A full sample application for a fake candidate is in [docs/sample](docs/sample).

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
```

Your data stays out of the plugin, in `~/resume-forge-data/` (or `$RESUME_FORGE_HOME`). Keep it as a **private** repo so `info.json` and everything you sent are versioned and backed up:

```
gh repo create resume-forge-data --private --clone   # run in ~
```

```
~/resume-forge-data/
  info.json                      your facts + evidence
  applications/2026-09-26-acme/  job.md  resume.tex/pdf  cover.tex/pdf  review.md  advices.md
```

`advices.md` has requirement coverage, honest answers for your gaps, likely questions, and a prep checklist.

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
