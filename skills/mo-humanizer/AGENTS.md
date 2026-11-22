# Guide for agents

This file explains how to change Humanizer without breaking its package or prompt.

## What this repo contains

Humanizer is an agent skill written in Markdown. `SKILL.md` is the prompt that agents read. The repo has no build step.

Keep the skill portable. Do not write instructions that limit it to one or two agent tools.

## Key files

- `SKILL.md` is the source of truth and the only prompt. It holds the portable YAML metadata, an account of why AI text sounds the way it does, and 32 numbered patterns grouped in seven sections and ordered by strength and frequency.
- `references/arabic-watchlists.md` holds the Arabic form of every watch list. `SKILL.md` sends the agent to it when the text is Arabic.
- `references/technical-integrity.md` holds the checks for commands, code, citations, and markup. `SKILL.md` sends the agent to it when the text is technical or carries sources.
- `README.md` explains installation, use, and patterns.
- `CHANGELOG.md` holds the release notes, newest first. Old notes keep the pattern numbers their release used.
- `.claude-plugin/plugin.json` describes the Claude plugin and points its skill loader at the root `SKILL.md`.
- `.claude-plugin/marketplace.json` lets users add this repo as a Claude marketplace.
- `.cursor-plugin/plugin.json` describes the Cursor plugin. Omit a `skills` path so Cursor loads the root `SKILL.md`.
- `agents/openai.yaml` holds the display name, short description, and default prompt for OpenAI-compatible agents.
- `scripts/validate-package.py` checks package files and shared values.

The folder in the OpenCode skills hub is `mo-humanizer`, and the skill name in the metadata is `mo-humanizer` as well. Folder and name match, so copy the folder as it is.

Upstream: [blader/humanizer](https://github.com/blader/humanizer), MIT licensed. This copy adds Arabic support, the technical and source integrity checks, and the two reference files. Keep the upstream license and attribution.

## Rules for changes

Keep `SKILL.md` and `README.md` in sync.

- **Patterns:** Patterns are numbered from 1 without gaps, strongest and most frequent first. A new tell earns a pattern only when no existing pattern already implies it; prefer folding it into an existing pattern. If you add, remove, or renumber a pattern, update the README tables, the README section title, and every §reference. The validator derives the count from the headings and checks that README pattern names match them.
- **References:** A file in `references/` must be named by `SKILL.md` as a path in backticks, and `SKILL.md` must send the agent to it when the job needs it. The validator checks that every named file exists.
- **Version:** Keep the same version in `SKILL.md` under `metadata.version`, the first `CHANGELOG.md` heading, `.claude-plugin/plugin.json`, and `.cursor-plugin/plugin.json`. Do not add a top-level `version` field to the skill.
- **Compatibility:** Keep install and use instructions neutral across agents. Names such as Claude Code, Cursor, OpenCode, and Codex are examples, not limits.
- **Description:** The plugin manifests use the first sentence of the `SKILL.md` description.
- **Length:** Every word of `SKILL.md` is read on each use. The validator caps it at 6,500 words; a change that adds words should earn them. Put long material in `references/` instead.
- **One prompt:** Only `SKILL.md` may carry skill frontmatter. A second file with a `name:` field can register a duplicate skill under the same name. The validator rejects it.
- **History:** Add a short `CHANGELOG.md` note for any behavior change or non-obvious fix.
- **Checks:** Before publishing, run `python3 scripts/validate-package.py`, `npx skills add . --list`, and `claude plugin validate .`.

## Writing style

Use Plain Language in code comments, prompts, documentation, descriptions, validation messages, and progress reports.

- Lead with the main point.
- Use common words and active voice.
- Keep sentences and paragraphs short.
- Use one term for the same item.
- Use `must` for requirements.
- Use headings, lists, and tables when they help the reader.
- Remove repeated or unnecessary words.
- Limit acronyms and explain technical terms.
- Avoid double negatives.
- Keep exact identifiers, commands, paths, schema fields, quotations, watched phrases, and behavior-bearing examples.
- Keep the full technical meaning.
- Write the Arabic watch lists in natural Arabic. Do not translate the English lists word for word, and do not mix languages inside one phrase.

## Editing the skill

- Keep the YAML metadata valid.
- Treat the prompt below the metadata as the product.
- Prefer a short, clear instruction over another exception or repeated explanation.
