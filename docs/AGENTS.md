# Agents

The repository ships **8 agents** in `agents/`. Two are primary agents you can select directly; six are subagents.

| Agent | File | Mode |
|-------|------|------|
| [`code-simplifier`](#code-simplifier) | `agents/code-simplifier.md` | subagent |
| [`accessibility-expert`](#accessibility-expert) | `agents/accessibility-expert.md` | subagent |
| [`code-reviewer`](#code-reviewer) | `agents/code-reviewer.md` | subagent |
| [`documentation-updater`](#documentation-updater) | `agents/documentation-updater.md` | subagent |
| [`seo-expert`](#seo-expert) | `agents/seo-expert.md` | subagent |
| [`ux-ui-expert`](#ux-ui-expert) | `agents/ux-ui-expert.md` | subagent |
| [`security-expert`](#security-expert) | `agents/security-expert.md` | primary |
| [`web-developer`](#web-developer) | `agents/web-developer.md` | primary |

## Shared permission model

Seven of the eight agents use the same safety envelope:

- **Scoped work** — `external_directory: deny` is listed last, and the last matching rule wins, so reads, writes, and shell targets outside the workspace are blocked.
- **Approval gate** — `edit` is set to `ask`, so the agent proposes changes and applies them only after you approve.
- **Reference access** — `webfetch`, `websearch`, and connected MCP tools (`*_*`) are allowed for docs, standards, and CVE/SEO references.
- **Focused skills** — each agent allows only the skills its job needs.

`code-simplifier` is the exception: it defines only a `description` and `mode` and inherits the default permissions.

## `code-simplifier`

**File:** `agents/code-simplifier.md` · **Mode:** `subagent`

Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.

### Behavior

- Preserves functionality: never changes what the code does, only how.
- Applies project standards (ES modules, `function` keyword, explicit return types, React patterns, error handling, naming).
- Enhances clarity: reduces complexity/nesting, eliminates redundant code, improves readability, consolidates logic, removes obvious comments.
- Avoids nested ternaries; prefers switch/if-else.
- Maintains balance: avoids over-simplification that hurts clarity or removes helpful abstractions.
- Focuses scope on recently modified code unless told otherwise.

### Refinement process

1. Identify recently modified code sections.
2. Analyze for elegance/consistency improvements.
3. Apply project-specific best practices.
4. Ensure functionality unchanged.
5. Verify simpler and more maintainable.
6. Document only significant changes.

## `accessibility-expert`

**File:** `agents/accessibility-expert.md` · **Mode:** `subagent`

Frontend accessibility expert: audits against WCAG 2.2 AA, proposes fixes, and applies them only after approval.

- **Skill:** `frontend-accessibility`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `subagent: deny` (leaf agent — it never launches other subagents), `external_directory: deny`

## `code-reviewer`

**File:** `agents/code-reviewer.md` · **Mode:** `subagent`

Expert reviewer for code changes: reviews, proposes fixes, applies them only after approval.

- **Skills:** `code-review`, `performance-optimizer`, `systematic-debugging`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## `documentation-updater`

**File:** `agents/documentation-updater.md` · **Mode:** `subagent`

Keeps docs accurate and in sync with code; proposes changes and applies them only after approval.

- **Skill:** `update-documentation`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## `seo-expert`

**File:** `agents/seo-expert.md` · **Mode:** `subagent`

Audits on-page, technical, and content SEO, proposes fixes, applies them only after approval.

- **Skill:** `seo-audit`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## `ux-ui-expert`

**File:** `agents/ux-ui-expert.md` · **Mode:** `subagent`

Designs and reviews UI/UX and graphics; proposes changes and applies them only after approval.

- **Skill:** `web-design`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## `security-expert`

**File:** `agents/security-expert.md` · **Mode:** `primary`

Cybersecurity expert: audits source code, secrets, dependencies, and IaC for vulnerabilities and misconfigurations, proposes fixes, applies them only after approval. Triggered by "check security", "find vulnerabilities", "is this code secure", "pentest", or mentions of CVEs, secrets, or security headers.

- **Skill:** `security-audit`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## `web-developer`

**File:** `agents/web-developer.md` · **Mode:** `primary`

Senior web developer for Astro, Vue, TypeScript, and modern frontend work. Works only inside the current project. This is the `default_agent` in `opencode.jsonc`.

- **Skills:** `systematic-debugging`, `performance-optimizer`, `website-analyzer`
- **Permissions:** `edit: ask`, web access allowed, MCP allowed, `external_directory: deny`

## Installation

Copy the agent files you want into `~/.config/opencode/agents/`:

```powershell
# Windows
Copy-Item .\agents\* "$env:USERPROFILE\.config\opencode\agents\" -Recurse
```

```bash
# macOS / Linux
cp agents/*.md ~/.config/opencode/agents/
```

Or run `.\install.ps1 -Agents` / `./install.sh --agents`, which also installs the skills those agents expect from this repo. Restart OpenCode to load them.
