# Versioning Policy — When and How to Bump

This skill follows SemVer (`MAJOR.MINOR.PATCH`), recorded in `VERSION`
(one line, e.g. `1.0.0`) and described in `CHANGELOG.md`.

## What each bump means

- **MAJOR** (1.x → 2.0.0): breaking methodology change. Examples: section
  count/order changes, minimum counts change (Key 10 → other), new required
  script CLI flags, workspace layout change, dropped builder contract
  (cards-only/offline). Existing workspaces built with 1.x may need migration.
- **MINOR** (1.0 → 1.1.0): backward-compatible addition. Examples: new
  reference file, new script, new optional flag, new workspace-template file,
  new audit phase detail that does not invalidate old reports.
- **PATCH** (1.0.0 → 1.0.1): fix or clarification with no behavior change.
  Examples: typo fixes, extra examples, tightened wording, bug fix in a script
  that brings it in line with documented behavior.

## Bump checklist (do all of these, in order)

1. Edit the skill files.
2. Update `VERSION` to the new number.
3. Add a `CHANGELOG.md` entry under a new `## [x.y.z] — YYYY-MM-DD` heading
   (Added / Changed / Removed sections).
4. Update the version line in `SKILL.md` (`> Skill version: x.y.z`).
5. Re-run the self-test: scaffold a temp workspace, validate, build
   (see `README.md` § Self-test). All green before release.
6. Sync all installed copies (live skill dir ↔ repo mirror): copy the whole
   skill folder, then verify with a hash comparison — never let copies drift.
7. Commit with message `skill: bump x.y.z — <short reason>`.

## Rules

- Never bump the version without a `CHANGELOG.md` entry, and never add a
  changelog entry without bumping `VERSION`. The two always move together.
- One version = one coherent change set. Do not batch unrelated MAJOR changes
  into a single MINOR.
- Workspaces record the skill version that created them in `curriculum.json`
  (`"skill_version"`). When opening an old workspace with a newer skill, check
  the changelog for MAJOR migration notes first.
