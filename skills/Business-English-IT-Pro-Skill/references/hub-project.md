# Hub Project Mode — Tech-English-Hub repo (binding reference)

> This skill operates on the REAL project: `tech-english-hub/` (sibling of this `skill/` folder in the same repo)
> (Blogger + Google Drive + Apps Script). Read this before any audit, fix, or
> generation that touches the published curriculum.

## 1. Repo layout (live state — curriculum v10, 2026-10-11)

```text
tech-english-hub/
├── src/                                   <- SINGLE SOURCE OF TRUTH (edit only here)
│   ├── core/dayNNN-<slug>/lesson.md       <- 120 Core lessons (day001-...-day120-...)
│   ├── videos/videoNN-<slug>/             <- 50 indexed lessons: lesson.md + transcript.srt
│   │                                          (+1 known orphan dir + 2 planned TODO-only dirs, see §6)
│   ├── articles/articleNN-<slug>/         <- 50 indexed lessons: lesson.md, no transcripts by design
│   │                                          (+1 planned TODO-only dir, see §6)
│   ├── daily/dailyNN-<slug>/              <- 30 lessons: lesson.md + transcript.srt
│   ├── career/careerNN-<slug>/lesson.md   <- 80 lessons + career/README.md (track status)
│   └── itil/itilNN-<slug>/lesson.md       <- 40 lessons + itil/README.md (track status)
├── data/                                  <- served by Drive (GENERATED; do not hand-edit)
│   ├── curriculum/
│   │   ├── config.json                    <- "Tech English Hub v10 (Core 120 + Videos 50 +
│   │   │                                     Articles 50 + Daily 30 + Career 80 + ITIL 40 = 370...)"
│   │   ├── tracks.json                    <- 6 tracks: core 120 · videos 50 · articles 50 ·
│   │   │                                     daily 30 (A1-B1) · career 80 · itil 40 (all B2-C1
│   │   │                                     except daily)
│   │   ├── core-index.json                <- 120 entries (day/file/title/level/mission/output/status/cat)
│   │   ├── videos-index.json              <- Video01-Video50 · articles-index.json: Article01-50
│   │   ├── daily-index.json               <- Daily01-30 · career-index.json: Career01-80
│   │   ├── itil-index.json                <- ITIL01-40
│   │   └── content/
│   │       ├── core-part1..4.json         <- 30-day chunks (001-030 ... 091-120)
│   │       ├── core-part5..6.json         <- empty retired placeholders (valid `[]`, bridge compat)
│   │       ├── videos-content.json · articles-content.json · daily-content.json
│   │       └── career-content.json · itil-content.json
│   └── users/                             <- learner accounts/progress — PRIVACY:
│       ├── progress.json                    (legacy shared progress)
│       └── users.json                       (per-learner accounts + progress)
│                                           never bulk-replace; users/ is upload-excluded
├── scripts/                               <- quality gates + mirror (see §3)
│   ├── validate.js · mirror-from-src.js · itil-batch-qa.js · audit-language.ps1 · README.md
├── Code.gs.txt                            <- Apps Script bridge v2.4.2, CACHE_VER v13
├── tech-english-hub-v9.4.5.html           <- LIVE Blogger page v9.4.5 (v6/v7/v8/v9.3.4 kept as history)
├── validate-output.txt · lang-audit.csv   <- generated audit artifacts (regenerate, don't trust)
└── docs/ · CHANGELOG.md · README.md       <- project docs (catalog-350.md keeps its legacy filename)
```

Naming/terminology (locked in every report): **Core = 120** · **Videos = 50** ·
**Articles = 50** · **Daily = 30** · **Career = 80** · **ITIL = 40** ·
**Total = 370 published lessons, 0 planned.**

## 2. CEFR bands + locked facts (from `data/curriculum/config.json`)

- Core: B2 Days 001–090 · C1 091–120 (deep-band demands: B2 ≤22 words/2-min
  speaking · C1 ≤26 / 3-min; Core-pattern 9 sections + optional leading
  `### Lesson Map`). Speaking task time equals the band time.
- Videos / Articles / Daily: Media 10-heading shape (Lesson Map + Context +
  Key Words + Key Phrases + Key Sentences + Collocations + Vocabulary
  Expansion + Common English Patterns + Real-World Dialogue + Speaking
  Practice); no Listening Notes (removed Batch 110), no authored Final Recall
  (live deck, pool ≥ 30). Videos + Daily ship `transcript.srt` next to
  `lesson.md`; article lessons have no transcripts by design. Videos /
  Articles / Career / ITIL: B2–C1.
- Daily: A1–B1 foundation track (A1×8 · A2×17 · B1×5), all published.
- Arabic tapers by band (locked): B2 English-first with glosses; C1 English-first
  with Arabic glosses for hard terms only. Columns always present.
- File facts: lesson bodies are CRLF, no BOM, end with `---`; video + daily
  lessons ship `transcript.srt` next to `lesson.md`; article lessons have no
  transcripts by design.

## 3. The hub tools (zero-dependency; Node ≥ 14 for the .js trio)

| Tool | Purpose | Command |
|---|---|---|
| `validate.js` | ALL hard gates + language reports: strict JSON, counts 120/50/50/30/80/40 (planned-aware indexes), index↔content alignment, index↔body title/level/mission alignment, CEFR distribution, locked section order (Core-pattern 9 for core/career/itil, Media 10 for videos/articles/daily), level lines, `---` markers, no-authored-Recall + live-pool ≥ 30 gates, src↔data mirrors, daily transcript.srt + Sources-link gates, telegraphic/short/whereas/signoff/duplicate reports. Exit 0 green / 1 hard gate / 2 `--strict` report-only. BOM-tolerant JSON loaders | `node scripts/validate.js [--strict]` (exit 0 green / 1 hard gate / 2 `--strict` report-only) |
| `mirror-from-src.js` | ONE-WAY sync src → `data/curriculum/content/` (bodies only — index titles/levels/missions are NOT refreshed, check alignment separately per Batch 112); DRY-RUN default; detect-and-keep formatting; `--tracks` selects tracks; `--rebuild` regenerates core parts; `status:"planned"` entries skipped | `node scripts/mirror-from-src.js --days 091-120 --write` · `--tracks videos,articles --write` · `--rebuild --write` (repairs JSON defects) |
| `itil-batch-qa.js` | Focused QA for `src/itil` (ITIL31–40 window): heading, Level line, 9 sections, minimums, pool ≥ 30, language stats | `node scripts/itil-batch-qa.js` |
| `audit-language.ps1` | Node-free per-day language audit on Core src (PS 5.1): telegraphic ≤4-word collocation examples, short-sentence share, band aggregates, CSV export | `./scripts/audit-language.ps1 -ExportCsv lang-audit.csv` |

CI: `.github/workflows/validate.yml` runs `node tech-english-hub/scripts/validate.js`
on every push/PR touching `tech-english-hub/`.

## 4. Golden rule + batch workflow

`src/` is the ONLY place lessons change. Every change follows the 7-step batch:

1. Edit in `src/` only.
2. `node scripts/validate.js` — hard gates green.
3. `node scripts/mirror-from-src.js --days <changed> --write` (or `--tracks <track>`).
4. Re-run `validate.js` (mirror took).
5. Upload changed files from `data/curriculum/` to Drive `curriculum/` ONLY —
   never touch `users/`.
6. Bump `CACHE_VER` in `Code.gs` (current `v13`; requires Apps Script redeploy
   as a New version — old caches otherwise serve stale content ~6 hours).
7. Record the batch in the repo CHANGELOG.

## 5. Deployment model (for context — never "fix" it)

- Blogger front-end v9.3.4 + Apps Script bridge v2.4.2 (`?action=lesson&track=core&day=NNN`,
  plus per-track `get`, `bootstrap-lite` counts+levels, version-first flow),
  Drive-hosted curriculum JSON, client cache keyed by `CACHE_VER`.
- Two-folder Drive layout inside ONE shared root: local `data/curriculum/` →
  Drive `curriculum/` (wholesale-replaceable) and local `data/users/` →
  Drive `users/` (append/protect only). Root folder shared "Anyone with the
  link – Viewer"; root folder ID pasted into `Code.gs` `FOLDER_ID`.

## 6. Known published-state facts (regenerate with the tools — never trust stale docs)

- `src/videos/` holds **53 dirs for 50 indexed lessons**: `video03-create-knowledge-base-sharepoint/`
  is an orphan (the index `Video03` points at `video03-intune-core-services-entra-id-portal/`);
  `video41-proxmox-ve-backups-and-snapshots/` and
  `video50-enterprise-backup-and-disaster-recovery-with-veeam/` are
  `status:"planned"` TODO-only dirs (no `lesson.md` — skipped by the mirror).
  Do not delete outright — archive per batch convention, then re-validate.
- `src/articles/article31-azure-backup-recovery-vaults/` is a `status:"planned"`
  TODO-only dir (no `lesson.md`).
- `core-part5.json` / `core-part6.json` are empty retired placeholders (`[]`) —
  expected, bridge-compatible, not a defect.
- `mirror-from-src.js` syncs bodies only: index titles/levels/missions can drift
  (Batch 112) — check index↔body alignment before every release.
- `validate-output.txt` and `lang-audit.csv` at the project root are generated
  artifacts: re-run the tools instead of quoting them.
- Doc lag to know: `scripts/README.md` still says "Media 11 sections" and the repo
  README state table still shows page v9.3.4 (live page is v9.4.5) — where prose
  disagrees with `validate.js` or `data/curriculum/*-index.json`, the tools and
  indexes win.
- Historical plans and audit trails live in `docs/archive/`; where numbers
  disagree with `data/curriculum/*-index.json`, the indexes win.

## 7. What the skill does NOT do here

- No edits outside `tech-english-hub/src/` (data/, users/, books, plan files).
- No re-rendering of site design beyond per-lesson content (page v9 shell is
  frozen: hero, search, TTS `data-say`, dark mode, progress; the standalone V3
  shell in this skill's `scripts/` is for workspace mode only).
- No standalone review/gate/summit/project lessons on any track — review lives
  inside every lesson (`natural-english.md` §5).
- No scratch/test/temp files inside the repo (Temp dir + delete after); `git
  status` before closing shows only intended files.
- Session-hardened operating rules (`references/session-rules.md`, distilled
  from `LESSONS-LEARNED.md`) are binding for every hub batch — read them
  before authoring, copy their pre-publish checklist into the batch.
