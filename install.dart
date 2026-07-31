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

void main(List<String> args) {
  final kitPath = Directory.current.absolute.path;
  final agentsFile = File('$kitPath${Platform.pathSeparator}AGENTS.md');
  if (!agentsFile.existsSync()) {
    stderr.writeln(
      'AGENTS.md not found in $kitPath. Run install.dart from '
      'the kit root.',
    );
    exit(1);
  }

  // 1. CodeBuddy — user-level skills symlink.
  // 1. CodeBuddy —— 用户级 skills 软链。
  final cb = toolSkillsDir('codebuddy');
  if (cb != null) linkKitForTool('codebuddy', cb, kitPath);

  // 2. Claude Code — user-level skills symlink.
  // 2. Claude Code —— 用户级 skills 软链。
  final cl = toolSkillsDir('claude');
  if (cl != null) linkKitForTool('claude', cl, kitPath);

  // 3. Cursor / Copilot — no user-level concept; place into CURRENT project.
  // Detect by walking up for a pubspec.yaml; if found, drop the entry there.
  // 3. Cursor / Copilot —— 没有用户级概念，写入「当前项目」。
  // 向上查找 pubspec.yaml 定位项目根，若找到则把入口放到该处。
  final projectRoot = _findProjectRoot(kitPath);
  if (projectRoot != null) {
    placeProjectEntry(
      '$projectRoot${Platform.pathSeparator}.cursorrules',
      agentsFile,
    );
    placeProjectEntry(
      '$projectRoot${Platform.pathSeparator}.github'
      '${Platform.pathSeparator}copilot-instructions.md',
      agentsFile,
    );
  } else {
    print(
      '[info] No Flutter project found above this kit; skipped '
      'Cursor/Copilot project entries. Run install.dart inside a project '
      'to wire those tools.',
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
