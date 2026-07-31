<h1 align="center">Flutter Agent Kit</h1>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="许可：MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.3%2B-blue.svg" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11%2B-0175C2.svg" alt="Dart"></a>
  <img src="https://img.shields.io/badge/AI-Agent-orange.svg" alt="AI 智能体">
  <img src="https://img.shields.io/badge/Skills-CodeBuddy%20%7C%20Claude%20Code-blueviolet.svg" alt="技能">
  <img src="https://img.shields.io/badge/工具-CodeBuddy%20%7C%20Claude%20Code%20%7C%20Cursor%20%7C%20Copilot-ff69b4.svg" alt="支持工具">
</p>

<p align="center">
  一套与工具无关的 Flutter / Dart 开发指引套件。
</p>

> [English](./README.md)

一套**与工具无关**的 Flutter / Dart 开发指引套件。它提供一份实质性指引——[`AGENTS.md`](./AGENTS.md)——作为**单一真相源**，外加 CodeBuddy 的 [`SKILL.md`](./SKILL.md) 包装、[`references/`](./references) 下的参考文档，以及 Dart 辅助脚本。同一份 `AGENTS.md` 也能被非 CodeBuddy 的工具直接读取，因此内容只维护一处。

## ✨ 包含什么

| 文件 / 目录 | 作用 |
|------------|------|
| [`AGENTS.md`](./AGENTS.md) | **核心指引**——架构、编码规范、依赖与版本、插件模式、校验命令。*单一真相源。* |
| [`SKILL.md`](./SKILL.md) | 仅 CodeBuddy 使用的自动加载包装（薄转发层，不重复内容）。 |
| [`references/`](./references) | 更深入的文档：[`flutter_style.md`](./references/flutter_style.md)、[`pubspec.md`](./references/pubspec.md)、[`architecture.md`](./references/architecture.md)、[`platform_channel.md`](./references/platform_channel.md)（覆盖 Android / iOS / Linux / macOS / Windows / Web / 鸿蒙）。 |
| [`scripts/dart/`](./scripts/dart) | Dart 辅助脚本（`*.dart`）。 |
| [`scripts/python/`](./scripts/python) | 同一组辅助脚本的 Python 版（`*.py`）。两者行为一致、CLI 相同：`verify`、`create_feature`、`bump_version`。 |
| [`install.dart`](./install.dart) / [`install.py`](./install.py) | 检测你使用的 AI 工具并把入口文件放到正确位置。Dart 或 Python 运行时任选其一。 |

## 🚀 安装（推荐）

按你已有的运行时选择——Dart SDK（任何 Flutter 开发者都已具备）或仅 Python 3。

```bash
git clone https://github.com/zero-labsco/flutter-agent-kit.git
cd flutter-agent-kit
dart run install.dart      # Dart 运行时
# 或 / or
python install.py          # Python 运行时
```

`install.dart` / `install.py` 会检测已安装的工具并自动接入本套件：

| 工具 | 安装脚本的行为 |
|------|----------------------|
| **CodeBuddy** | 将本套件软链到 `~/.codebuddy/skills/flutter-agent-kit/`（通过 `SKILL.md` 自动加载）。 |
| **Claude Code** | 软链到 `~/.claude/skills/flutter-agent-kit/`（同样读取 `SKILL.md`）。 |
| **Cursor** | 将 `AGENTS.md` 内容复制到项目的 `.cursorrules` / Cursor 规则。 |
| **GitHub Copilot**（VS Code） | 将 `AGENTS.md` 复制到当前项目的 `.github/copilot-instructions.md`。 |

随时可重跑安装脚本来更新（幂等）。

### 选项

| 参数 | 含义 | 是否可选 |
|------|------|----------|
| `-p, --project <path>` | Cursor/Copilot 入口写入的目标项目根目录。 | 可选（默认自动查找最近的 Flutter 项目） |
| `-t, --tool <tool>` | 只接入单个工具：`codebuddy` \| `claude` \| `cursor` \| `copilot`。 | 可选（省略则接入所有已检测到的工具） |
| `-h, --help` | 打印用法并退出。 | 可选 |

支持 **cmd**、**PowerShell**、**bash**、**zsh** —— 路径含空格时加引号即可，
如 `-p "D:\My Project\app"`。

### 指定目标项目（非侵入式）

在 kit 目录运行安装脚本，并通过 `--project` 传入目标项目根目录。Cursor / Copilot 的入口会**直接写入该项目**，而不会从 kit 目录向上查找——kit 目录本身不会被改动。

```bash
dart run install.dart -p /path/to/my_project
# 或 / or
python install.py -p /path/to/my_project
```

> 由于安装脚本本就在 kit 目录运行，`-p`（`--project` 的简写）是指定目标项目最简洁的方式。省略则回退到从 kit 目录向上查找最近的 Flutter 项目。

### 只接入单个工具

使用 `-t <tool>`（`--tool` 的简写）只接入某一个工具。合法取值：
`codebuddy`、`claude`、`cursor`、`copilot`。不指定则接入所有已检测到的工具。

```bash
dart run install.dart -p /path/to/my_project -t cursor
# 或 / or
python install.py -p /path/to/my_project --tool copilot
```

## 🛠 辅助脚本（Dart + Python）

辅助脚本各提供两份：Dart 版在 [`scripts/dart/`](./scripts/dart)，Python 版在 [`scripts/python/`](./scripts/python)。按你已有的运行时选择其一即可，CLI 与行为完全一致。

| 脚本 | Dart | Python | 用途 |
|------|------|--------|------|
| **校验** | `dart run scripts/dart/verify.dart [--no-publish]` | `python scripts/python/verify.py [--no-publish]` | 运行 `flutter analyze` + `flutter test` + 发布预检。 |
| **创建功能** | `dart run scripts/dart/create_feature.dart <name>` | `python scripts/python/create_feature.py <name>` | 生成 `lib/features/<name>/{data,domain,presentation}/`。 |
| **升级版本** | `dart run scripts/dart/bump_version.dart <major\|minor\|patch>` | `python scripts/python/bump_version.py <major\|minor\|patch>` | 升级 `pubspec.yaml` 并打印 git tag 命令。 |

## 📦 安装（手动兜底）

若脚本无法检测你的环境，可手动放置文件：

- **CodeBuddy / Claude Code**：把本文件夹复制到 `~/.codebuddy/skills/` 或 `~/.claude/skills/`。
- **Cursor**：把 [`AGENTS.md`](./AGENTS.md) 复制到项目的 `.cursorrules`。
- **Copilot**：把 [`AGENTS.md`](./AGENTS.md) 复制到项目的 `.github/copilot-instructions.md`。

## 🔄 更新

拉取最新代码后重跑 `dart run install.dart`（或 `python install.py`）。

## 📄 许可证

基于 [MIT 许可证](./LICENSE) 发布。
