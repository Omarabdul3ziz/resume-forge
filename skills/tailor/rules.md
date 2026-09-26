# Writing rules

The reader is a hiring manager skimming 300 resumes, then a technical interviewer who will ask "how?" about every line. Write for both.

## Honesty (hard rules)

- Use only facts in `info.json`. No new jobs, titles, dates, technologies, or scope.
- Numbers come only from a `metric` whose `evidence` is filled. Copy the metric's form exactly ("~3x", not "3x"). No evidence, no number: describe the work plainly instead.
- Don't upgrade verbs. "Contributed to" stays "contributed to"; "mentored" is not "led".
- Every line must survive "walk me through that" in an interview.
- A job requirement with no matching fact is a gap. List it in `advices.md`; never cover it on the resume.

## Resume

- Max 2 pages. Page 2 must be worth reading, or cut to 1.
- Order jobs newest first. Inside a job, the project most relevant to this job goes first.
- Max 4 bullets per project, max 2 lines (~230 chars) per bullet. Drop projects that don't help this application, but every job keeps at least one project: never drop a job.
- A job with `via` (contractor or agency work for a client) renders as `\role{<Title> at <name>}{via <via> \textbar{} City, Country \textbar{} Mon YYYY -- Present}`.
- Bullets start with a past-tense verb, even for the current job ("Built", not "Building" or "I built"). No "responsible for", "worked on", "helped with": say what you did.
- Bullet = what you built + the concrete mechanism (tool, technique) + the result if a real one exists. Don't bolt a vague result on the end ("..., improving reliability").
- Mirror the job's wording where it's honestly the same thing (they say "observability", you did Prometheus/Grafana: use their word).
- Skills: only what appears in `info.json` and matters for this job. Keep the level markers ("primary", "basic").
- No summary/objective paragraph. One `\headline` line under the name is allowed: the job's exact title when it's honestly the user's title or work (from `info.json`), else delete it.
- Dates as `Mon YYYY -- Present`, from `info.json`. Ask the user when a month is missing.

## Getting through the ATS

ATS rank and search; recruiters search by job title and exact terms. So:

- `keywords.txt`: your honest judgment of every must-have in the job (tools, skills, title, years, degree), one per line, in the job's exact wording:
  - `match: <term> -- <info.json fact>`: `info.json` shows it, even under another name (they say "message queues", you did RabbitMQ).
  - `partial: <term> -- <what's close>`: related but not the same (they want AWS, you have GCP).
  - `gap: <term>`: nothing in `info.json`.
  `check.sh` turns this into the FIT score (partial = half) and fails if a matched term's exact wording is missing from the PDF text (terms with numbers, like "5+ years", are judged from the dates instead). Judge by meaning, not spelling, and be strict: when in doubt it's partial. Nice-to-haves don't go in.
- Put each matched term in a bullet where it was used, not only in Skills.
- Acronyms: write both forms once, like the job does ("Continuous Integration (CI)").
- Keep the standard headings (Experience, Skills, Education, Personal Projects), single column, no tables, icons, or images.
- Never hide text (white text, tiny fonts, instructions to AI screeners). Parsers show it to the recruiter.
- Workday, Taleo, iCIMS, and SuccessFactors make you re-type the resume into form fields: `resume.txt` is for that.

## Voice (this is what avoids AI slop)

- Write like an engineer explaining their work to a senior peer: plain, specific, a little dry.
- Specific nouns beat adjectives. "veth + netns" beats "modern networking".
- Don't start every bullet with the same verb family, and don't force every bullet into the same shape. Some are short.
- No em-dashes inside bullets. No "X, enabling Y" or "X, ensuring Y" tails.
- Banned words live in `banned.txt`; `check.sh` enforces them.

## Cover letter

- 3 short paragraphs, max 300 words, 1 page.
  1. The role and the one reason you fit (your strongest match to their main problem).
  2. One or two stories from `info.json` with context the resume can't give: the problem, what you did, what you learned. Don't repeat resume lines.
  3. What you'd work on in the first months, based on the job description. One closing line.
- No "I am excited/thrilled/passionate", no flattery about the company, no generic mission talk. Name one specific thing about their product or stack if the job description gives one.

## advices.md

Short lists, direct instructions. Coverage is already in `keywords.txt`; don't repeat it.

1. **Gaps**: how to answer each one honestly in an interview, and what to do about it.
2. **Likely questions**: technical + behavioral, specific to this company/role.
3. **Stories to prepare**: 3–4 from `info.json`, each as situation → action → result.
