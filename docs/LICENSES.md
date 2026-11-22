# Licenses

## Collection

The collection itself is provided as-is. No single license covers the whole repository, because skills are aggregated from multiple upstream projects under different terms. See [`../LICENSE`](../LICENSE) for the collection-level note.

## Skill-level license files

Files that exist on disk:

| Skill | License file(s) |
|-------|-----------------|
| `frontend-design` | `skills/frontend-design/LICENSE.txt` |
| `theme-factory` | `skills/theme-factory/LICENSE.txt` |
| `skill-creator` | `skills/skill-creator/LICENSE.txt` |
| `deep-research` | `skills/deep-research/UPSTREAM-LICENSE.txt` (Apache-2.0), `skills/deep-research/UPSTREAM-NOTICE.md` |
| `mo-humanizer` | `skills/mo-humanizer/LICENSE` (MIT) |
| `powershell-enterprise-admin` | `skills/powershell-enterprise-admin/LICENSE`, plus vendored copies under `M365-Auth-Modules-main/`, `SCCM-OSD-Deployment-Kit-main/`, and `powershell-enterprise-admin-skill-main/` |

## License declared in frontmatter only

These skills state a license in `SKILL.md` frontmatter but ship **no** license file. Include the upstream notice yourself if you redistribute them:

| Skill | Declared license | Source recorded in frontmatter |
|-------|------------------|-------------------------------|
| `impeccable` | Apache 2.0 | — |
| `markitdown` | MIT | K-Dense Inc. |
| `agent-memory-systems` | Apache 2.0 (upstream `vibeship-spawner-skills`) | `vibeship-spawner-skills` |

## Skills with a recorded source but no license

These record provenance in frontmatter (`source:`) without a license field. Treat them as **all rights reserved** until you confirm terms upstream:

| Skill | Recorded source |
|-------|-----------------|
| `clean-code` | ClawForge — https://github.com/jackjin1997/ClawForge |
| `ui-skills` | https://github.com/ibelick/ui-skills |
| `deep-research` | https://github.com/sanjay3290/ai-skills/…/deep-research |
| `agent-memory-mcp`, `agent-memory-systems`, `backend-architect`, `code-documentation-doc-generate`, `code-refactoring-refactor-clean`, `file-organizer`, `frontend-developer`, `software-architecture`, `ui-ux-designer`, `ui-ux-pro-max` | `community` |
| `business-english-it-pro`, `jobfit-intelligence`, `powershell-enterprise-admin`, `opencode-skill-creator`, `impeccable`, `design-*`, `ui-*` (2026 group), `branding-identity`, `responsive-design`, `ux-design`, `ui-patterns`, `agent-ui-design`, `ai-design-workflow`, `writing-plans`, `interview-me`, `review-resume`, `tailored-resume-generator`, `seo-audit`, `security-audit`, `performance-optimizer`, `frontend-accessibility`, `update-documentation`, `code-review` | not recorded |

The `business-english-it-pro` skill is original work by this repository's author.

## Plugin

`plugins/skill-creator/` is licensed Apache-2.0 (see `plugins/skill-creator/package.json`). It is an adaptation of Anthropic's `skill-creator` for Claude Code, ported to TypeScript for OpenCode.

## Upstream sources

- [openskills.cc/skills](https://openskills.cc/skills): most single-purpose skills.
- [web-dev-agent](https://github.com/Domenico-Tenace-Open-Labs/web-dev-agent): the 8 agents, 3 rules, and the review/audit skill group.
- Individual authors named in each `SKILL.md` frontmatter.

Respect upstream licenses and terms when redistributing any skill. If you add a skill, add its license file and record the source in `SKILL.md`.
