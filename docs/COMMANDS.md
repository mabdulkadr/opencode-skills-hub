# Commands

Three slash commands ship in `commands/`. Each file is a Markdown prompt with a `description` frontmatter field; `$ARGUMENTS` is replaced with the text typed after the command.

| Command | File | Description |
|---------|------|-------------|
| [`/code-review`](#code-review) | `commands/code-review.md` | Code review a pull request |
| [`/doc-compress`](#doc-compress) | `commands/doc-compress.md` | Compress memory docs into caveman format |
| [`/scaffold-frontend-project`](#scaffold-frontend-project) | `commands/scaffold-frontend-project.md` | Scaffold a new frontend project |

## `/code-review`

**File:** `commands/code-review.md`

**Description:** Code review a pull request.

### Usage

```
/code-review <PR number or URL>
```

### Workflow

1. Eligibility check (Haiku agent): skip if the PR is closed, draft, trivial/automated, or already reviewed.
2. Collect relevant `CLAUDE.md` file paths.
3. Summarize the PR (Haiku agent).
4. Launch 5 parallel Sonnet agents:
   - `CLAUDE.md` compliance audit
   - Shallow bug scan on changes
   - Git blame/history context
   - Previous PRs touching same files
   - Code comments compliance
5. Score each issue 0–100 (Haiku agents); keep issues ≥ 80.
6. Re-check eligibility.
7. Comment results on the PR via `gh`.

### Notes

- Does not build or typecheck; assumes CI handles that.
- Requires the `gh` CLI, authenticated.
- Output format is fixed in the command file.

## `/doc-compress`

**File:** `commands/doc-compress.md`

**Description:** Compress natural language memory files (`AGENTS.md`, todos, preferences) into caveman format to save input tokens. Preserves all technical substance, code, URLs, and structure.

### Usage

```
/doc-compress [file]
```

### Behavior

- Rewrites the target file in compressed form, **overwriting the original**.
- Saves a human-readable backup as `FILE.original.md`.
- Keeps code blocks, URLs, and headings intact — only prose is compressed.

### Notes

- Destructive by design: the backup is the rollback path.
- Best used on memory/instruction files, not on documentation you publish.

## `/scaffold-frontend-project`

**File:** `commands/scaffold-frontend-project.md`

**Description:** Scaffold a new frontend project from scratch — pnpm only, initial 3-page site.

### Usage

```
/scaffold-frontend-project <projectType> <projectName> [dependencies]
```

### Notes

- Uses `pnpm` exclusively.
- Produces an initial three-page site rather than an empty skeleton.

## Installation

Copy command files to `~/.config/opencode/commands/`:

```powershell
# Windows
Copy-Item .\commands\* "$env:USERPROFILE\.config\opencode\commands\"
```

```bash
# macOS / Linux
cp commands/*.md ~/.config/opencode/commands/
```

Or run `.\install.ps1 -Commands` / `./install.sh --commands`. Restart OpenCode to load them.
