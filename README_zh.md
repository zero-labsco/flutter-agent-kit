# Flutter Agent Kit

一套**与工具无关**的 Flutter / Dart 开发指引套件。它提供一份实质性指引（`AGENTS.md`），外加 CodeBuddy 的 `SKILL.md` 包装、参考文档和 Dart 辅助脚本。同一份 `AGENTS.md` 也能被非 CodeBuddy 的工具直接读取，因此内容保持单一真相源。

[English](./README.md)

## 包含什么
- `AGENTS.md` —— 核心指引（架构、编码规范、依赖与版本、插件模式、校验命令）。**单一真相源。**
- `SKILL.md` —— 仅 CodeBuddy 使用的自动加载包装（薄转发层，不重复内容）。
- `references/` —— 更深入的文档：`flutter_style.md`、`pubspec.md`、`architecture.md`、`platform_channel.md`（覆盖 Android / iOS / Linux / macOS / Windows / Web / 鸿蒙）。
- `scripts/dart/` —— Dart 辅助脚本（`*.dart`）。
- `scripts/python/` —— 同一组辅助脚本的 Python 版（`*.py`）。两者行为一致、CLI 相同：`verify`、`create_feature`、`bump_version`。
- `install.dart` —— 检测你使用的 AI 工具并把入口文件放到正确位置。

## 安装（推荐）
需要 Dart SDK（任何 Flutter 开发者都已具备）。
```bash
git clone https://github.com/zero-labsco/flutter-agent-kit.git
cd flutter-agent-kit
dart run install.dart
```
`install.dart` 会检测已安装的工具并自动接入本套件：

| 工具 | install.dart 的行为 |
|------|---------------------|
| CodeBuddy | 将本套件软链到 `~/.codebuddy/skills/flutter-agent-kit/`（通过 `SKILL.md` 自动加载）。 |
| Claude Code | 软链到 `~/.claude/skills/flutter-agent-kit/`（同样读取 `SKILL.md`）。 |
| Cursor | 将 `AGENTS.md` 内容复制到项目的 `.cursorrules` / Cursor 规则。 |
| GitHub Copilot (VS Code) | 将 `AGENTS.md` 复制到当前项目的 `.github/copilot-instructions.md`。 |

随时可重跑 `install.dart` 来更新（幂等）。

## 辅助脚本（Dart + Python）
辅助脚本各提供两份：Dart 版在 `scripts/dart/`，Python 版在 `scripts/python/`。按你已有的运行时选择其一即可，CLI 与行为完全一致。

| 脚本 | Dart | Python | 用途 |
|------|------|--------|------|
| 校验 | `dart run scripts/dart/verify.dart [--no-publish]` | `python scripts/python/verify.py [--no-publish]` | 运行 `flutter analyze` + `flutter test` + 发布预检。 |
| 创建功能 | `dart run scripts/dart/create_feature.dart <name>` | `python scripts/python/create_feature.py <name>` | 生成 `lib/features/<name>/{data,domain,presentation}/`。 |
| 升级版本 | `dart run scripts/dart/bump_version.dart <major\|minor\|patch>` | `python scripts/python/bump_version.py <major\|minor\|patch>` | 升级 `pubspec.yaml` 并打印 git tag 命令。 |

## 安装（手动兜底）
若脚本无法检测你的环境，可手动放置文件：
- **CodeBuddy / Claude Code**：把本文件夹复制到 `~/.codebuddy/skills/` 或 `~/.claude/skills/`。
- **Cursor**：把 `AGENTS.md` 复制到项目的 `.cursorrules`。
- **Copilot**：把 `AGENTS.md` 复制到项目的 `.github/copilot-instructions.md`。

## 更新
拉取最新代码后重跑 `dart run install.dart`。

## 许可证
见本仓库的 `LICENSE`。
