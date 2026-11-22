#!/usr/bin/env bash
# OpenCode Skills Hub - Installer (macOS/Linux)
# Usage: ./install.sh [--all|--skills|--agents|--commands|--rules]
set -e
CFG="$HOME/.config/opencode"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ALL=0; SKILLS=0; AGENTS=0; COMMANDS=0; RULES=0
if [ $# -eq 0 ]; then ALL=1; else
  for arg in "$@"; do
    case "$arg" in
      --all) ALL=1 ;;
      --skills) SKILLS=1 ;;
      --agents) AGENTS=1 ;;
      --commands) COMMANDS=1 ;;
      --rules) RULES=1 ;;
    esac
  done
fi
if [ "$ALL" = "1" ]; then SKILLS=1; AGENTS=1; COMMANDS=1; RULES=1; fi

mkdir -p "$CFG/skills" "$CFG/agents" "$CFG/commands" "$CFG/rules"

merge_copy() {
  # $1 = src dir, $2 = dst dir
  src="$1"; dst="$2"
  mkdir -p "$dst"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    if [ -d "$item" ]; then
      merge_copy "$item" "$dst/$name"
    else
      cp -f "$item" "$dst/$name"
    fi
  done
}

[ "$SKILLS" = "1" ]   && merge_copy "$ROOT/skills"   "$CFG/skills"   && echo "Installed skills"
[ "$AGENTS" = "1" ]   && merge_copy "$ROOT/agents"   "$CFG/agents"   && echo "Installed agents"
[ "$COMMANDS" = "1" ] && merge_copy "$ROOT/commands" "$CFG/commands" && echo "Installed commands"
[ "$RULES" = "1" ]    && merge_copy "$ROOT/rules"    "$CFG/rules"    && echo "Installed rules"

echo "Done. Restart OpenCode to load."
