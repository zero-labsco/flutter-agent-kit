---
name: flutter-agent-kit
description: This skill provides general Flutter/Dart development guidance - implementing features, fixing bugs, managing pubspec dependencies and version constraints, following effective_dart, structuring lib/ (feature-first architecture, state management selection), writing platform channels for plugins, running flutter analyze/flutter test, and publishing to pub.dev. Use it for any Flutter or Dart project task.
---

# Flutter Agent Kit

## Overview
This skill activates for any Flutter / Dart project work. The substantive, tool-agnostic guidance (architecture, coding conventions, dependency/version rules, plugin platform-channel patterns, and verification commands) lives in `AGENTS.md` at the repository root of this kit.

`AGENTS.md` is read by CodeBuddy as well as other AI coding tools (Claude Code, Cursor, GitHub Copilot, Codex, etc.). It is the single source of truth; this skill avoids duplicating it.

## How to use
1. Read `AGENTS.md` from this kit's root.
2. Follow its architecture, conventions, and commands for any Flutter/Dart task.
3. The Dart-based helper scripts under `scripts/` can be run directly in a terminal by any developer.

This skill exists only so CodeBuddy auto-loads the project guide through the trigger described in the frontmatter. For non-CodeBuddy tools, the same `AGENTS.md` is consumed directly (see `README.md` for placement per tool).
