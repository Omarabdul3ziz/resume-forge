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
- Max 4 bullets per project, max 2 lines (~230 chars) per bullet. Drop projects that don't help this application.
- Bullet = what you built + the concrete mechanism (tool, technique) + the result if a real one exists. Don't bolt a vague result on the end ("..., improving reliability").
- Mirror the job's wording where it's honestly the same thing (they say "observability", you did Prometheus/Grafana: use their word).
- Skills: only what appears in `info.json` and matters for this job. Keep the level markers ("primary", "basic").
- No summary/objective section.

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

Short lists, direct instructions:

1. **Coverage**: table of each job requirement → matching bullet, or `GAP`.
2. **Gaps**: how to answer honestly in an interview, and what to do about them.
3. **Likely questions**: technical + behavioral, specific to this company/role.
4. **Stories to prepare**: 3–4 from `info.json`, each as situation → action → result.
5. **Prep checklist**: coding / system design / behavioral, only what this role tests.
6. **"As a hiring manager, here's what would make me more likely to invite you for an interview:"** what to change, cut, or expand, and what the resume signals.
