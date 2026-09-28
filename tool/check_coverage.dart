// Los constructores con nombre no pueden usar la sintaxis abreviada `new`
// de Dart.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'dart:convert';
import 'dart:io';

/// Resumen de cobertura por líneas obtenido del reporte LCOV de Flutter.
final class CoverageReport {
  const new(this.files);

  factory CoverageReport.parse(String source) {
    final files = <String, CoverageCount>{};
    String? path;
    int? found;
    int? hit;

    void finishRecord() {
      if (path != null) {
        if (found == null || hit == null) {
          throw const FormatException('Missing LF/LH counts in LCOV');
        }
        if (found! < 0 || hit! < 0 || hit! > found!) {
          throw const FormatException('Invalid LF/LH counts in LCOV');
        }
        if (path!.startsWith('lib/') && !path!.startsWith('lib/l10n/gen/')) {
          files[path!] = CoverageCount(hit: hit!, lines: found!);
        }
      }
      path = null;
      found = null;
      hit = null;
    }

    for (final line in const LineSplitter().convert(source)) {
      if (line.startsWith('SF:')) {
        path = _normalizePath(line.substring(3));
      } else if (line.startsWith('LF:')) {
        found = int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        hit = int.parse(line.substring(3));
      } else if (line == 'end_of_record') {
        finishRecord();
      }
    }
    if (path != null) finishRecord();
    if (files.isEmpty) throw const FormatException('No lib/ files in LCOV');
    return CoverageReport(files);
  }

  final Map<String, CoverageCount> files;

  CoverageCount get total => _sum(files.values);

  CoverageCount forPrefix(String prefix) => _sum(
    files.entries
        .where((entry) => entry.key.startsWith(prefix))
        .map((entry) => entry.value),
  );

  static CoverageCount _sum(Iterable<CoverageCount> counts) => CoverageCount(
    hit: counts.fold(0, (sum, count) => sum + count.hit),
    lines: counts.fold(0, (sum, count) => sum + count.lines),
  );

  static String _normalizePath(String value) {
    final path = value.replaceAll(RegExp(r'\\'), '/');
    if (path.startsWith('lib/')) return path;
    final index = path.indexOf('/lib/');
    return index < 0 ? path : path.substring(index + 1);
  }
}

final class CoverageCount {
  const new({required this.hit, required this.lines});

  final int hit;
  final int lines;

  double get percent => lines == 0 ? 0 : hit * 100 / lines;
}

/// Devuelve todas las validaciones fallidas para que CI las informe
/// en una sola ejecución.
List<String> coverageFailures(CoverageReport report) {
  final failures = <String>[];
  const minimum = 90.0;
  final areas = <String, CoverageCount>{
    'total': report.total,
    'domain': report.forPrefix('lib/features/breeds/domain/'),
    'data': report.forPrefix('lib/features/breeds/data/'),
    'blocs': report.forPrefix('lib/features/breeds/presentation/bloc/'),
  };
  for (final entry in areas.entries) {
    if (entry.value.lines == 0 || entry.value.percent < minimum) {
      failures.add(
        '${entry.key}: ${entry.value.percent.toStringAsFixed(1)}% '
        '(minimum ${minimum.toStringAsFixed(0)}%)',
      );
    }
  }

  const requiredFiles = [
    'lib/features/breeds/domain/entities/breed.dart',
    'lib/features/breeds/domain/use_cases/search_breeds.dart',
    'lib/features/breeds/data/repositories/breeds_repository_impl.dart',
    'lib/features/breeds/data/sources/dio_breeds_remote_data_source.dart',
    'lib/features/breeds/presentation/bloc/breeds_catalog_bloc.dart',
    'lib/features/breeds/presentation/bloc/breed_detail_bloc.dart',
  ];
  for (final path in requiredFiles) {
    if (!report.files.containsKey(path)) {
      failures.add('Missing from LCOV: $path');
    }
  }
  return failures;
}

void main() {
  try {
    final report = CoverageReport.parse(
      File('coverage/lcov.info').readAsStringSync(),
    );
    for (final (name, count) in [
      ('total', report.total),
      ('domain', report.forPrefix('lib/features/breeds/domain/')),
      ('data', report.forPrefix('lib/features/breeds/data/')),
      ('blocs', report.forPrefix('lib/features/breeds/presentation/bloc/')),
    ]) {
      stdout.writeln(
        '$name: ${count.percent.toStringAsFixed(1)}% '
        '(${count.hit}/${count.lines} lines)',
      );
    }
    final failures = coverageFailures(report);
    if (failures.isNotEmpty) {
      failures.forEach(stderr.writeln);
      exitCode = 1;
    }
  } on FileSystemException catch (_) {
    stderr.writeln('Missing coverage/lcov.info. Run flutter test --coverage.');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('Invalid LCOV: ${error.message}');
    exitCode = 1;
  }
}
