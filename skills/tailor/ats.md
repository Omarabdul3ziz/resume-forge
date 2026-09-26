# ATS guide

Find the ATS from the job URL, or from the "Apply" link on the page (company career pages often send you to one of these). Write it at the top of `job.md` as `ATS: <name>` (or `ATS: unknown`), then follow its row on top of rules.md.

| URL contains | ATS | What to do |
|---|---|---|
| `myworkdayjobs.com`, `workday.com` | Workday | Makes you re-type the resume into form fields: tell the user to keep `resume.txt` open. Parsing of dates and titles is strict, so keep `Mon YYYY -- Present` and one title per role. Some employers add AI ranking (HiredScore): the job's exact title and must-have terms matter. |
| `taleo.net`, `oraclecloud.com` | Taleo / Oracle | Literal keyword matching. Use the job's exact spelling for every matched must-have, and spell out acronyms both ways. Plainest layout wins. |
| `icims.com` | iCIMS | Parses into form fields and recruiters search by keyword. Check the autofilled fields before submitting. |
| `successfactors.com`, `jobs.sap.com` | SAP SuccessFactors | Form-heavy like Workday: keep `resume.txt` ready. |
| `greenhouse.io` | Greenhouse | Parses PDF well and the reviewer usually reads the PDF itself. The cover letter field is often optional: attach it anyway. Recruiters search by keyword. |
| `lever.co` | Lever | Parses PDF well; search matches word stems. The reviewer reads the PDF. Links in the "additional information" box are read: add GitHub there. |
| `ashbyhq.com` | Ashby | Parses PDF well; some teams use its AI-assisted review, which reads for fit against the job text. |
| `smartrecruiters.com` | SmartRecruiters | Parses into a profile; check the autofilled fields. |
| `workable.com` | Workable | Parses PDF well; may ask screening questions, answer them from `info.json`. |
| `personio.de`, `personio.com`, `recruitee.com`, `bamboohr.com`, `teamtailor.com` | Personio / Recruitee / BambooHR / Teamtailor | Smaller-company ATS, usually read by a person directly. Write for the hiring manager first. |
| `linkedin.com/jobs` (Easy Apply) | LinkedIn | The recruiter sees your LinkedIn profile next to the resume: the headline advice in `advices.md` matters more here. |
| anything else | unknown | Follow rules.md as is. |

Always: PDF from this tool is fine for every ATS above. Never add hidden text for AI screeners.
