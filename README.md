<h1 align="center">Flutter Agent Kit</h1>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.3%2B-blue.svg" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11%2B-0175C2.svg" alt="Dart"></a>
  <img src="https://img.shields.io/badge/AI-Agent-orange.svg" alt="AI Agent">
  <img src="https://img.shields.io/badge/Skills-CodeBuddy%20%7C%20Claude%20Code-blueviolet.svg" alt="Skills">
  <img src="https://img.shields.io/badge/tools-CodeBuddy%20%7C%20Claude%20Code%20%7C%20Cursor%20%7C%20Copilot-ff69b4.svg" alt="Tools">
</p>

<p align="center">
  A tool-agnostic guidance kit for Flutter / Dart development.
</p>

> [中文](./README_zh.md)

A **tool-agnostic** guidance kit for Flutter / Dart development. It ships one
substantive guide — [`AGENTS.md`](./AGENTS.md) — as the **single source of truth**,
plus a CodeBuddy [`SKILL.md`](./SKILL.md) wrapper, reference docs under
[`references/`](./references), and Dart helper scripts. The same `AGENTS.md` is
consumed directly by non-CodeBuddy tools, so the content stays in one place.

## ✨ What's inside

| File / folder | Purpose |
|---------------|---------|
| [`AGENTS.md`](./AGENTS.md) | **Core guidance** — architecture, conventions, dependencies, plugin pattern, verify commands. *Single source of truth.* |
| [`SKILL.md`](./SKILL.md) | CodeBuddy-only auto-load wrapper (thin forwarder, no duplicate content). |
| [`references/`](./references) | Deeper docs: [`flutter_style.md`](./references/flutter_style.md), [`pubspec.md`](./references/pubspec.md), [`architecture.md`](./references/architecture.md), [`platform_channel.md`](./references/platform_channel.md) (Android / iOS / Linux / macOS / Windows / Web / OpenHarmony). |
| [`scripts/dart/`](./scripts/dart) | Helper scripts in Dart (`*.dart`). |
| [`scripts/python/`](./scripts/python) | The same helper scripts in Python (`*.py`). Identical behavior & CLI: `verify`, `create_feature`, `bump_version`. |
| [`install.dart`](./install.dart) / [`install.py`](./install.py) | Detects your AI tool and places/soft-links the right entry file. Pick the Dart or Python runtime. |

## 🚀 Install (recommended)

Pick whichever runtime you have — the Dart SDK (any Flutter dev already has it)
or just Python 3.

```bash
git clone https://github.com/zero-labsco/flutter-agent-kit.git
cd flutter-agent-kit
dart run install.dart      # Dart runtime
# or / 或
python install.py          # Python runtime
```

`install.dart` / `install.py` detects installed tools and wires up the kit:

| Tool | What the installer does |
|------|--------------------------|
| **CodeBuddy** | Symlinks this kit into `~/.codebuddy/skills/flutter-agent-kit/` (auto-loads via `SKILL.md`). |
| **Claude Code** | Symlinks into `~/.claude/skills/flutter-agent-kit/` (also reads `SKILL.md`). |
| **Cursor** | Copies `AGENTS.md` content into the project's `.cursorrules` / Cursor rules. |
| **GitHub Copilot** (VS Code) | Copies `AGENTS.md` into the current project's `.github/copilot-instructions.md`. |

Re-run the installer any time to update (idempotent).

## 🛠 Helper scripts (Dart + Python)

The helpers ship twice — once in Dart under [`scripts/dart/`](./scripts/dart) and once
in Python under [`scripts/python/`](./scripts/python). Pick whichever runtime you have;
the CLI and behavior are identical.

| Script | Dart | Python | Purpose |
|--------|------|--------|---------|
| **Verify** | `dart run scripts/dart/verify.dart [--no-publish]` | `python scripts/python/verify.py [--no-publish]` | Runs `flutter analyze` + `flutter test` + publish dry-run. |
| **Create feature** | `dart run scripts/dart/create_feature.dart <name>` | `python scripts/python/create_feature.py <name>` | Scaffolds `lib/features/<name>/{data,domain,presentation}/`. |
| **Bump version** | `dart run scripts/dart/bump_version.dart <major\|minor\|patch>` | `python scripts/python/bump_version.py <major\|minor\|patch>` | Bumps `pubspec.yaml` and prints the git tag command. |

## 📦 Install (manual fallback)

If the script can't detect your environment, place the files yourself:

- **CodeBuddy / Claude Code**: copy this folder to `~/.codebuddy/skills/` or `~/.claude/skills/`.
- **Cursor**: copy [`AGENTS.md`](./AGENTS.md) into your project's `.cursorrules`.
- **Copilot**: copy [`AGENTS.md`](./AGENTS.md) into your project's `.github/copilot-instructions.md`.

## 🔄 Updating

Pull latest and re-run `dart run install.dart` (or `python install.py`).

## 📄 License

Released under the [MIT License](./LICENSE).
