#!/usr/bin/env dart
// verify.dart — runs the local pre-push verification suite for a Flutter project.
//
// Usage:  dart run scripts/verify.dart [--no-publish]
// Runs:  flutter analyze, flutter test, and (unless skipped) flutter pub publish --dry-run.
// Exits non-zero if any step fails, so it can gate CI or a pre-push hook.

import 'dart:io';

/// Runs [cmd] with [args] in the current directory; returns its exit code.
Future<int> run(String cmd, List<String> args) async {
  print('\n> $cmd ${args.join(' ')}');
  final result = await Process.run(cmd, args,
      runInShell: true, stdout: stdout, stderr: stderr);
  return result.exitCode;
}

Future<void> main(List<String> args) async {
  final skipPublish = args.contains('--no-publish');

  // 1. Static analysis.
  if (await run('flutter', ['analyze']) != 0) {
    stderr.writeln('flutter analyze failed.');
    exit(1);
  }

  // 2. Tests.
  if (await run('flutter', ['test']) != 0) {
    stderr.writeln('flutter test failed.');
    exit(1);
  }

  // 3. Publish dry-run (skipped for apps / private packages).
  if (!skipPublish) {
    if (await run('flutter', ['pub', 'publish', '--dry-run']) != 0) {
      stderr.writeln('flutter pub publish --dry-run failed.');
      exit(1);
    }
  }

  print('\nAll checks passed.');
}
