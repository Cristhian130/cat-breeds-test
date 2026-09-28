import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visual levels only depend on their own or lower Atomic level', () {
    const levels = ['atoms', 'molecules', 'organisms', 'templates'];
    const roots = [
      'lib/core/design_system',
      'lib/features/breeds/presentation',
    ];
    final visualImport = RegExp(
      "^import 'package:cat_breeds/(?:core/design_system|features/breeds/presentation)/([^/]+)/",
      multiLine: true,
    );
    final violations = <String>[];

    for (final root in roots) {
      for (final level in levels) {
        final folder = Directory('$root/$level');
        if (!folder.existsSync()) continue;
        for (final file in folder.listSync().whereType<File>()) {
          if (!file.path.endsWith('.dart')) continue;
          final source = file.readAsStringSync();
          if (RegExp(
            "^import '(?:package:bloc/|package:flutter_bloc/|package:dio/|package:get_it/|package:cat_breeds/features/breeds/presentation/bloc/)",
            multiLine: true,
          ).hasMatch(source)) {
            violations.add('${file.path}: visual level imports infrastructure');
          }
          for (final match in visualImport.allMatches(source)) {
            final importedLevel = match.group(1);
            final importedIndex = levels.indexOf(importedLevel ?? '');
            if (importedIndex > levels.indexOf(level)) {
              violations.add(
                '${file.path}: $level imports higher level $importedLevel',
              );
            }
          }
        }
      }
    }

    expect(violations, isEmpty);
  });
}
