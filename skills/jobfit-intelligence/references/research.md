# Research — Salary Methodology, Claim IDs, Company Research

## Search budget (speed rule)

| Mode | Searches | Sources ledger |
|---|---|---|
| Full lane | ≤ 6 (batch salary+market+company where possible) | ≤ 8 claims |
| Quick lane | ≤ 3 (1 salary band, 1 market context, optional 1 company fact) | ≤ 4 claims |

Batch queries hard: one search must answer more than one question when the SERP allows. A blocked/empty result is recorded once with `[Sxxx] weak-data` and then MOVED ON — never re-search a dead query.

Use the mapped web-search capability. Prefer: government labor data, official salary reports, reputable platforms (levels/Glassdoor/Payscale/Talent.com), Big-4/recruiter reports, job posts with published bands. Minimum 2 independent sources for salary; 3 preferred.

## Salary Research Rules (→ REPORT.md §6)

1. Prefer the exact job title.
2. Match country first.
3. Match city when sufficient data exists.
4. Match seniority.
5. Match industry when possible.
6. Separate base salary from total compensation.
7. Separate monthly and annual figures.
8. Record sample size when available.
9. Record publication and access dates.
10. Never combine incomparable datasets into one range without explaining the normalization.
11. If sources materially disagree, report the disagreement instead of averaging blindly.

Report table (cite claim IDs inline, e.g. `SAR 28,000–35,000/mo [S001][S002]`):

| | Monthly | Annual | Notes |
|---|---|---|---|
| Low | | | |
| Typical | | | |
| High | | | |

Plus per row: currency, base-vs-total split, bonus/benefits/housing/transport/allowances, YoE + industry + company-size + employment-type + localization assumptions, and a Confidence line (high/medium/low + why).

Saudi-specific rules (why: KSA bands are misread often): monthly SAR primary, annual secondary; JD city UNKNOWN → price at Riyadh and note Jeddah ≈ 5–10% below, remote/giga-project sites ≈ 15–25% above + accommodation; most reported figures bundle allowances; all salaries tax-free; never present one job ad as a market range — pair every ad with a guide/aggregator.

If data is weak or web search is unavailable: print exactly — "Reliable current salary data was not sufficient to establish a precise range." — then give a wide directional band labeled `directional-estimate-only`. Never invent numbers, never reuse another country's band without stating the substitution.

## Market & Company (→ REPORT.md §6)

Market: demand signal, common stack/certs, typical YoE, emerging skills, salary trend. No unsupported placement promises.
Company — collect only relevant public facts: company, industry, location, size when reliable, main products/services, publicly documented tech environment, recent developments relevant to the role, official careers page, role/team info when available. Prefer official company sources; third-party only for independent context; distinguish company claims from independent reporting. Company UNKNOWN → say so, never invent.

## Claim ledger (→ SOURCES.md)

One block per claim ID:

```text
[S001]
Claim: <one line>
Source: <name + URL>
Published: <date or UNKNOWN>
Accessed: YYYY-MM-DD
Used in: REPORT.md §6, index.html Salary card
Reliability: high | medium | low (+ why)
```

No fabricated URLs. QA must be able to walk every `[Sxxx]` from REPORT.md to SOURCES.md.
