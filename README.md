# Flutter Agent Kit

[中文](./README_zh.md)

A tool-agnostic guidance kit for Flutter / Dart development. It ships one substantive
guide (`AGENTS.md`) plus a CodeBuddy `SKILL.md` wrapper, reference docs, and Dart helper
scripts. The same `AGENTS.md` is consumed directly by non-CodeBuddy tools, so the content
stays in a single source of truth.

## What's inside
- `AGENTS.md` — core guidance (architecture, conventions, dependencies, plugin pattern, verify commands). **Single source of truth.**
- `SKILL.md` — CodeBuddy-only auto-load wrapper (thin forwarder, no duplicate content).
- `references/` — deeper docs: `flutter_style.md`, `pubspec.md`, `architecture.md`, `platform_channel.md`.
- `scripts/` — Dart helpers: `verify.dart`, `create_feature.dart`, `bump_version.dart`.
- `install.dart` — detects your AI tool and places/soft-links the right entry file.

## Install (recommended)
Requires the Dart SDK (any Flutter dev already has it).
```bash
git clone https://github.com/zero-labsco/flutter-agent-kit.git
cd flutter-agent-kit
dart run install.dart
```
`install.dart` detects installed tools and wires up the kit:

| Tool | What install.dart does |
|------|------------------------|
| CodeBuddy | Symlinks this kit into `~/.codebuddy/skills/flutter-agent-kit/` (auto-loads via `SKILL.md`). |
| Claude Code | Symlinks into `~/.claude/skills/flutter-agent-kit/` (also reads `SKILL.md`). |
| Cursor | Copies `AGENTS.md` content into the project's `.cursorrules` / Cursor rules. |
| GitHub Copilot (VS Code) | Copies `AGENTS.md` into the current project's `.github/copilot-instructions.md`. |

Re-run `install.dart` any time to update (idempotent).

## Install (manual fallback)
If the script can't detect your environment, place the files yourself:
- **CodeBuddy / Claude Code**: copy this folder to `~/.codebuddy/skills/` or `~/.claude/skills/`.
- **Cursor**: copy `AGENTS.md` into your project's `.cursorrules`.
- **Copilot**: copy `AGENTS.md` into your project's `.github/copilot-instructions.md`.

## Updating
Pull latest and re-run `dart run install.dart`.

## License
See `LICENSE` in this repository.
