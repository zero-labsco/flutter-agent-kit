#!/usr/bin/env dart
// install.dart — wires the flutter-agent-kit into the developer's AI tools.
// install.dart — 将 flutter-agent-kit 接入开发者的各类 AI 工具。
//
// Detects installed tools and places/soft-links the appropriate entry file so
// the kit's AGENTS.md (single source of truth) is consumed by each tool.
// 自动检测已安装的工具，并将合适的入口文件放置或软链过去，
// 让各工具都能读取本套件的 AGENTS.md（单一真相源）。
// Run with: `dart run install.dart`
// 运行方式：`dart run install.dart`
//
// Optional: pass a target project root so Cursor/Copilot entries are placed
// there directly, instead of scanning upward from the kit folder.
// 可选：传入目标项目根目录，让 Cursor/Copilot 入口直接写入该项目，
// 而不是从 kit 目录向上查找。
//   dart run install.dart --project /path/to/my_project
//   dart run install.dart /path/to/my_project
//   dart run install.dart -p /path/to/my_project -t cursor   # only Cursor
//   dart run install.dart -h                                  # show help
//
// All flags are optional; run with no args to wire every detected tool.
// 所有参数均可选；不带参数运行即接入所有已检测到的工具。
//
// Cross-platform (Windows / macOS / Linux). Idempotent: re-running is safe.
// 跨平台（Windows / macOS / Linux），且幂等：重复运行不会产生副作用。

import 'dart:io';

/// Resolves the user-level skills base directory for a given tool.
/// 解析某工具的用户级 skills 根目录。
/// Returns null if the tool is not detected on this machine.
/// 若本机未检测到该工具则返回 null。
String? toolSkillsDir(String tool) {
  final home =
      Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE']; // Windows uses USERPROFILE
  // Windows 使用 USERPROFILE 作为主目录
  if (home == null) return null;

  switch (tool) {
    case 'codebuddy':
      // Windows: %USERPROFILE%\.codebuddy ; POSIX: ~/.codebuddy
      // 用户级 skills 目录：Windows 与类 Unix 路径一致。
      return pathJoin(home, ['.codebuddy', 'skills']);
    case 'claude':
      return pathJoin(home, ['.claude', 'skills']);
    default:
      return null;
  }
}

/// Joins path segments with the platform separator.
/// 用平台分隔符拼接路径片段。
String pathJoin(String base, Iterable<String> parts) =>
    [base, ...parts].join(Platform.pathSeparator);

/// Soft-links (or copies, on platforms without link support) the kit folder
/// into the target tool's skills directory.
/// 将套件目录软链（或拷贝，于不支持软链的平台）到目标工具的 skills 目录。
void linkKitForTool(String tool, String skillsDir, String kitPath) {
  final target = Directory(pathJoin(skillsDir, ['flutter-agent-kit']));
  if (target.existsSync()) {
    print('[skip] $tool: ${target.path} already present');
    return;
  }
  Directory(skillsDir).createSync(recursive: true);
  try {
    // Use a symlink so updates are picked up without re-installing.
    // 使用软链，这样套件更新后无需重新安装即可生效。
    Link(target.path).createSync(kitPath);
    print('[link] $tool -> ${target.path}');
  } on FileSystemException {
    // Fallback: deep copy (Windows may block links without privileges).
    // 兜底：整目录拷贝（Windows 可能因权限不足而禁止创建软链）。
    _copyDir(Directory(kitPath), target);
    print('[copy] $tool -> ${target.path}');
  }
}

/// Copies AGENTS.md content into a project-level entry for tools that have no
/// user-level skills directory (Cursor / Copilot consume per-project files).
/// 将 AGENTS.md 内容拷贝到项目级入口，供没有用户级 skills 目录的工具使用
/// （Cursor / Copilot 读取的是项目级文件）。
void placeProjectEntry(String entryPath, File source) {
  final file = File(entryPath);
  if (file.existsSync()) {
    print('[skip] project entry already exists: $entryPath');
    return;
  }
  file.parent.createSync(recursive: true);
  source.copySync(entryPath);
  print('[copy] AGENTS.md -> $entryPath');
}

void _copyDir(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(recursive: false)) {
    final name = entity.path.split(Platform.pathSeparator).last;
    if (entity is File) {
      entity.copySync('${to.path}${Platform.pathSeparator}$name');
    } else if (entity is Directory) {
      _copyDir(entity, Directory('${to.path}${Platform.pathSeparator}$name'));
    }
  }
}

/// Parses CLI args. Returns the explicitly passed project root (or null).
/// 解析命令行参数，返回显式传入的项目根目录（未传则返回 null）。
/// Accepts `--project <path>` or a bare positional `<path>`.
/// 支持 `--project <path>` 或裸位置参数 `<path>`。
String? parseProjectArg(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--project' || a == '-p') {
      if (i + 1 < args.length) return args[i + 1];
    } else if (a.startsWith('--project=')) {
      return a.split('=').last;
    } else if (!a.startsWith('-') && i == args.length - 1) {
      // A bare trailing path argument.
      // 末尾的裸路径参数。
      return a;
    }
  }
  return null;
}

/// Parses the optional `--tool` / `-t` filter (or null = wire all tools).
/// 解析可选的 `--tool` / `-t` 过滤（null 表示接入全部工具）。
/// Valid values: codebuddy, claude, cursor, copilot.
/// 合法取值：codebuddy、claude、cursor、copilot。
String? parseToolArg(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--tool' || a == '-t') {
      if (i + 1 < args.length) return args[i + 1].toLowerCase();
    } else if (a.startsWith('--tool=')) {
      return a.split('=').last.toLowerCase();
    }
  }
  return null;
}

/// Prints the usage text and exits.
/// 打印用法说明并退出。
void printUsage() {
  print('''
Flutter Agent Kit installer — wires AGENTS.md into your AI tools.

Usage / 用法:
  dart run install.dart [options]

Options / 选项:
  -p, --project <path>   Target project root for Cursor/Copilot entries.
                         Cursor/Copilot 入口写入的目标项目根目录。
  -t, --tool <tool>      Wire only one tool: codebuddy|claude|cursor|copilot.
                         只接入单个工具（不指定则接入全部已检测到的工具）。
  -h, --help             Show this help and exit. 显示帮助并退出。

Examples / 示例:
  dart run install.dart
  dart run install.dart -p /path/to/project
  dart run install.dart -p /path/to/project -t cursor
''');
}

void main(List<String> args) {
  // Show help and exit early (works in any shell: cmd / pwsh / bash).
  // 提前显示帮助并退出（在 cmd / pwsh / bash 等任意 shell 下均可用）。
  if (args.contains('-h') || args.contains('--help')) {
    printUsage();
    return;
  }

  final kitPath = Directory.current.absolute.path;
  final agentsFile = File('$kitPath${Platform.pathSeparator}AGENTS.md');
  if (!agentsFile.existsSync()) {
    stderr.writeln(
      'AGENTS.md not found in $kitPath. Run install.dart from '
      'the kit root.',
    );
    exit(1);
  }

  // Resolve the optional tool filter. null means "wire every detected tool".
  // 解析可选的工具过滤；null 表示「接入所有已检测到的工具」。
  final onlyTool = parseToolArg(args);
  final wire = (String tool) => onlyTool == null || onlyTool == tool;

  // 1. CodeBuddy — user-level skills symlink.
  // 1. CodeBuddy —— 用户级 skills 软链。
  if (wire('codebuddy')) {
    final cb = toolSkillsDir('codebuddy');
    if (cb != null) linkKitForTool('codebuddy', cb, kitPath);
  }

  // 2. Claude Code — user-level skills symlink.
  // 2. Claude Code —— 用户级 skills 软链。
  if (wire('claude')) {
    final cl = toolSkillsDir('claude');
    if (cl != null) linkKitForTool('claude', cl, kitPath);
  }

  // 3. Cursor / Copilot — no user-level concept; place into a target project.
  // Use an explicitly passed --project path if given; otherwise walk up from
  // the kit folder looking for a pubspec.yaml.
  // 3. Cursor / Copilot —— 没有用户级概念，写入「目标项目」。
  // 若显式传入 --project 则用之；否则从 kit 目录向上查找 pubspec.yaml。
  final projectArg = parseProjectArg(args);
  final projectRoot = projectArg != null
      ? Directory(projectArg).absolute.path
      : _findProjectRoot(kitPath);
  if (projectRoot != null) {
    if (wire('cursor')) {
      placeProjectEntry(
        '$projectRoot${Platform.pathSeparator}.cursorrules',
        agentsFile,
      );
    }
    if (wire('copilot')) {
      placeProjectEntry(
        '$projectRoot${Platform.pathSeparator}.github'
        '${Platform.pathSeparator}copilot-instructions.md',
        agentsFile,
      );
    }
  } else if (onlyTool == 'cursor' || onlyTool == 'copilot') {
    print(
      '[info] No target project resolved (no --project arg and no Flutter '
      'project found above this kit). Re-run with --project <path> to wire '
      'Cursor/Copilot.',
    );
  }

  print('\nDone. Re-run anytime to update. See README.md for manual fallback.');
}

/// Walks up from [start] looking for a pubspec.yaml (a Flutter/Dart project).
/// 从 [start] 向上查找 pubspec.yaml（即 Flutter/Dart 项目根）。
String? _findProjectRoot(String start) {
  var dir = Directory(start);
  while (true) {
    if (File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) return null; // reached filesystem root
    dir = parent;
  }
}
