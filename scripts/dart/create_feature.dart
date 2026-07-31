#!/usr/bin/env dart
// create_feature.dart — scaffolds a feature-first folder under lib/features.
// create_feature.dart — 在 lib/features 下生成「功能优先」结构的目录骨架。
//
// Usage:  dart run scripts/dart/create_feature.dart <feature_name>
// 用法：  dart run scripts/dart/create_feature.dart <feature_name>
// Example: dart run scripts/dart/create_feature.dart auth
// 示例：  dart run scripts/dart/create_feature.dart auth
// Creates: lib/features/auth/{data,domain,presentation}/ with a barrel file.
// 生成：  lib/features/auth/{data,domain,presentation}/，并附 barrel 导出文件。

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run scripts/create_feature.dart <feature_name>',
    );
    exit(1);
  }
  final name = args.first.trim();
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('Feature name must be snake_case starting with a letter.');
    exit(1);
  }

  final base =
      Directory.current.absolute.path +
      Platform.pathSeparator +
      'lib'
          '${Platform.pathSeparator}features${Platform.pathSeparator}$name';

  for (final layer in ['data', 'domain', 'presentation']) {
    final dir = Directory('$base${Platform.pathSeparator}$layer');
    dir.createSync(recursive: true);
    // Place a barrel per layer for convenient imports.
    // 每个分层放置一个 barrel 文件，方便统一导入。
    File(
        '$base${Platform.pathSeparator}$layer${Platform.pathSeparator}$name'
        '_$layer.dart',
      )
      ..createSync()
      ..writeAsStringSync('// $name $layer layer.\n');
  }

  // Feature-level barrel.
  // 功能级 barrel 文件，统一导出各分层。
  File('$base${Platform.pathSeparator}$name.dart')
    ..createSync()
    ..writeAsStringSync(
      'export \'$name/data/${name}_data.dart\';\n'
      'export \'$name/domain/${name}_domain.dart\';\n'
      'export \'$name/presentation/${name}_presentation.dart\';\n',
    );

  print('Created feature "$name" at lib/features/$name');
}
