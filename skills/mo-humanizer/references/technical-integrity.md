# Technical and source integrity

Read this file when the text is technical (IT, infrastructure, security, cloud, networking, scripting), when it carries citations, when it came from a document with sources, or when the user asks for a fact check rather than a style pass.

The rules here protect facts. A style edit that changes a claim, drops a limitation, or moves a citation is an error, not a cleanup.

## 1. What must survive the rewrite

Keep these exact, byte for byte, in the same script and the same case:

- Commands, arguments, parameter names, and flags.
- Code, inline code, code fences, and the language tag on a fence.
- Configuration keys, JSON keys, YAML keys, environment variables, and registry paths.
- File paths, URLs, API names, event IDs, and error messages.
- Product, vendor, and feature names.
- Versions, build numbers, and dates.
- Numbers with their units, and the direction of a comparison.

## 2. What must not change meaning

| The source says | The rewrite must not become |
|---|---|
| Correlation | Cause |
| Might, can, is expected to | Does, will |
| Requirement | Recommendation |
| Observed result | General rule |
| One environment | Every environment |
| A limitation | Nothing said about limits |
| A workaround | The official way |
| A fix in one account | A fix for all accounts |

Keep the difference between a requirement, a recommendation, a workaround, a limitation, and observed behavior. Each one tells the reader what to do.

## 3. Procedure integrity

When the text describes how to do something:

- Keep every prerequisite, permission, role, and prerequisite package.
- Keep the execution context: which host, which shell, which account, which subscription, which region.
- Keep rollback, cleanup, and verification steps.
- Keep failure handling, and keep the difference between a fatal error and a warning.
- Do not merge two commands into one if either has a side effect.
- Do not simplify a long command into a shorter one that means something else.

## 4. Platform and version differences

- Keep the difference between Windows PowerShell 5.1 and PowerShell 7, including parameter names such as `-Encoding` behavior, execution policy, and module loading.
- Keep the difference between `Invoke-WebRequest` and `Invoke-RestMethod`, and between `curl` and `curl.exe` on Windows.
- Keep the difference between cmd, PowerShell, bash, and zsh syntax.
- Keep the difference between a Windows path and a POSIX path, and keep both separators when the source shows both.
- Keep the difference between PowerShell 5.1 and PowerShell 7 in `Get-Content`, `Select-String`, and object formatting.
- Do not upgrade a command to a newer form because the newer one looks cleaner.

## 5. Do not change a technical term to avoid a watched word

These are exact, not inflated:

- robust authentication, robust networking
- key rotation, rotation policy
- gated deployment, feature gating, quality gate
- real-time monitoring, real-time replication
- deep-dive analysis, deep learning
- critical patch, critical alert
- landscape of threats, threat landscape
- showcase, when it means a demo of the product

The watch lists in `SKILL.md` cover prose habits, not vocabulary.

## 6. Citation and reference integrity

Check every citation in the text:

- Does the reference resolve?
- Does the DOI or ISBN point to the work that is cited?
- Does the citation sit with the claim it supports?
- Is it a search-results page or a news aggregator used in place of the original source?
- Are there reference definitions in the file that nothing cites?
- Do tracking parameters reveal a referral path without establishing authorship?

Never repair a reference by guessing. Keep the citation, flag it for verification, and correct it only after checking the authoritative source.

A missing citation is not a tell. Most writing is unsourced, and a style pass must not invent sources.

## 7. Markup and platform syntax

- Markdown headings or links inside a system that expects Wikitext, or the reverse.
- Unclosed code fences.
- Broken templates.
- Exposed HTML comments.
- Invalid internal links, categories, or anchors.
- Raw markup that a reader can see.
- YAML or JSON frontmatter that a style pass has reflowed.

Fix markup only when the target format is known. Do not convert formats blindly. During a prose pass, leave code blocks, link targets, and frontmatter alone.

## 8. Placeholders and drafting leftovers

- Bracketed fields such as `[Insert name]`, `[Add source]`, `[Enter date]`, `[Your Name]`.
- Token names such as `INSERT_SOURCE_URL`, `SOURCE_PUBLISHER`, `YYYY-XX-XX`.
- Example domains and dummy values in a document that reads as final.
- Arabic forms such as `[أدخل الاسم]` and `[أضف المصدر]`.

Replace a placeholder only when the correct value is available. Otherwise leave it and flag it. Never fabricate the missing value.

## 9. Leaked machine artifacts

- `contentReference[...]`, `oaicite`, and similar tool markers.
- Raw prompt instructions or hidden drafting notes.
- Unexplained JSON or metadata fragments in reader-facing prose.
- Chat wrappers such as "I hope this helps" or "Let me know if you want more".

Remove accidental artifacts. Keep them when the document is specifically about those formats.

## 10. Claims about verification

The text must not claim work that was not done:

- "I reviewed all available sources."
- "The references were verified."
- "The data is fully up to date."
- "All claims are supported."
- The Arabic forms «تم التحقق من جميع المصادر» and «جميع المعلومات موثقة».

Keep such a statement only when the work was actually done and can be shown. An edit that only rewrote wording checked no sources, and it must not say it did.

## 11. Fact-check diff

Run this against the source before returning the rewrite:

- [ ] No claim added or dropped.
- [ ] No number, date, unit, version, name, command, path, or quotation changed.
- [ ] No cause turned into a correlation, or the reverse.
- [ ] No possibility turned into a certainty.
- [ ] No requirement turned into a recommendation.
- [ ] No limitation, exception, warning, or dependency removed.
- [ ] No actor changed.
- [ ] No scope narrowed or widened.
- [ ] No citation dropped, moved, or attached to a claim it does not support.
- [ ] No ranking lost, and no simultaneity claim invented.

## 12. Flag, do not fix

When a technical statement looks wrong, do not silently correct it during a style pass. Report it separately as a possible factual issue, with the line that looks wrong and why. The writer decides.

Never invent test evidence, lab results, production experience, benchmarks, or vendor documentation.
