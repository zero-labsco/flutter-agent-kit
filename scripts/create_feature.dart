#!/usr/bin/env dart
// create_feature.dart — scaffolds a feature-first folder under lib/features.
//
// Usage:  dart run scripts/create_feature.dart <feature_name>
// Example: dart run scripts/create_feature.dart auth
// Creates: lib/features/auth/{data,domain,presentation}/ with a barrel file.

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run scripts/create_feature.dart <feature_name>');
    exit(1);
  }
  final name = args.first.trim();
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('Feature name must be snake_case starting with a letter.');
    exit(1);
  }

  final base =
      Directory.current.absolute.path + Platform.pathSeparator + 'lib'
      '${Platform.pathSeparator}features${Platform.pathSeparator}$name';

  for (final layer in ['data', 'domain', 'presentation']) {
    final dir = Directory('$base${Platform.pathSeparator}$layer');
    dir.createSync(recursive: true);
    // Place a barrel per layer for convenient imports.
    File('$base${Platform.pathSeparator}$layer${Platform.pathSeparator}$name'
        '_$layer.dart')
      ..createSync()
      ..writeAsStringSync('// $name $layer layer.\n');
  }

  // Feature-level barrel.
  File('$base${Platform.pathSeparator}$name.dart')
    ..createSync()
    ..writeAsStringSync(
        'export \'$name/data/${name}_data.dart\';\n'
        'export \'$name/domain/${name}_domain.dart\';\n'
        'export \'$name/presentation/${name}_presentation.dart\';\n');

  print('Created feature "$name" at lib/features/$name');
}
