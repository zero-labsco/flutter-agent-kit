#!/usr/bin/env dart
// verify.dart — runs the local pre-push verification suite for a Flutter project.
// verify.dart — 运行 Flutter 项目推送前的本地校验流程。
//
// Usage:  dart run scripts/dart/verify.dart [--no-publish]
// 用法：  dart run scripts/dart/verify.dart [--no-publish]
// Runs:  flutter analyze, flutter test, and (unless skipped) flutter pub publish --dry-run.
// 执行：  flutter analyze、flutter test，以及（除非跳过）flutter pub publish --dry-run。
// Exits non-zero if any step fails, so it can gate CI or a pre-push hook.
// 任一环节失败即以非零码退出，可用于 CI 或 pre-push 钩子拦截。

import 'dart:io';

/// Runs [cmd] with [args] in the current directory; returns its exit code.
/// Output is inherited to the terminal so the user sees analyze/test output.
Future<int> run(String cmd, List<String> args) async {
  print('\n> $cmd ${args.join(' ')}');
  final process = await Process.start(
    cmd,
    args,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  return await process.exitCode;
}

Future<void> main(List<String> args) async {
  final skipPublish = args.contains('--no-publish');

  // 1. Static analysis.
  // 1. 静态分析。
  if (await run('flutter', ['analyze']) != 0) {
    stderr.writeln('flutter analyze failed.');
    exit(1);
  }

  // 2. Tests.
  // 2. 运行测试。
  if (await run('flutter', ['test']) != 0) {
    stderr.writeln('flutter test failed.');
    exit(1);
  }

  // 3. Publish dry-run (skipped for apps / private packages).
  // 3. 发布预检（应用 / 私有包可加 --no-publish 跳过）。
  if (!skipPublish) {
    if (await run('flutter', ['pub', 'publish', '--dry-run']) != 0) {
      stderr.writeln('flutter pub publish --dry-run failed.');
      exit(1);
    }
  }

  print('\nAll checks passed.');
}
