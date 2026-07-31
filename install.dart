#!/usr/bin/env dart
// install.dart — wires the flutter-agent-kit into the developer's AI tools.
//
// Detects installed tools and places/soft-links the appropriate entry file so
// the kit's AGENTS.md (single source of truth) is consumed by each tool.
// Run with: `dart run install.dart`
//
// Cross-platform (Windows / macOS / Linux). Idempotent: re-running is safe.

import 'dart:io';

/// Resolves the user-level skills base directory for a given tool.
/// Returns null if the tool is not detected on this machine.
String? toolSkillsDir(String tool) {
  final home = Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE']; // Windows uses USERPROFILE
  if (home == null) return null;

  switch (tool) {
    case 'codebuddy':
      // Windows: %USERPROFILE%\.codebuddy ; POSIX: ~/.codebuddy
      return pathJoin(home, ['.codebuddy', 'skills']);
    case 'claude':
      return pathJoin(home, ['.claude', 'skills']);
    default:
      return null;
  }
}

/// Joins path segments with the platform separator.
String pathJoin(String base, Iterable<String> parts) =>
    [base, ...parts].join(Platform.pathSeparator);

/// Soft-links (or copies, on platforms without link support) the kit folder
/// into the target tool's skills directory.
void linkKitForTool(String tool, String skillsDir, String kitPath) {
  final target = Directory(pathJoin(skillsDir, ['flutter-agent-kit']));
  if (target.existsSync()) {
    print('[skip] $tool: ${target.path} already present');
    return;
  }
  Directory(skillsDir).createSync(recursive: true);
  try {
    // Use a symlink so updates are picked up without re-installing.
    Link(target.path).createSync(kitPath);
    print('[link] $tool -> ${target.path}');
  } on FileSystemException {
    // Fallback: deep copy (Windows may block links without privileges).
    _copyDir(Directory(kitPath), target);
    print('[copy] $tool -> ${target.path}');
  }
}

/// Copies AGENTS.md content into a project-level entry for tools that have no
/// user-level skills directory (Cursor / Copilot consume per-project files).
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
    stderr.writeln('AGENTS.md not found in $kitPath. Run install.dart from '
        'the kit root.');
    exit(1);
  }

  // 1. CodeBuddy — user-level skills symlink.
  final cb = toolSkillsDir('codebuddy');
  if (cb != null) linkKitForTool('codebuddy', cb, kitPath);

  // 2. Claude Code — user-level skills symlink.
  final cl = toolSkillsDir('claude');
  if (cl != null) linkKitForTool('claude', cl, kitPath);

  // 3. Cursor / Copilot — no user-level concept; place into CURRENT project.
  // Detect by walking up for a pubspec.yaml; if found, drop the entry there.
  final projectRoot = _findProjectRoot(kitPath);
  if (projectRoot != null) {
    placeProjectEntry(
        '$projectRoot${Platform.pathSeparator}.cursorrules', agentsFile);
    placeProjectEntry(
        '$projectRoot${Platform.pathSeparator}.github'
        '${Platform.pathSeparator}copilot-instructions.md',
        agentsFile);
  } else {
    print('[info] No Flutter project found above this kit; skipped '
        'Cursor/Copilot project entries. Run install.dart inside a project '
        'to wire those tools.');
  }

  print('\nDone. Re-run anytime to update. See README.md for manual fallback.');
}

/// Walks up from [start] looking for a pubspec.yaml (a Flutter/Dart project).
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
