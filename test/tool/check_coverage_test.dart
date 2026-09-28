import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage.dart';

void main() {
  test('parses Windows paths and ignores generated files', () {
    final report = CoverageReport.parse(r'''
SF:lib\features\breeds\domain\entities\breed.dart
LF:10
LH:9
end_of_record
SF:lib/l10n/gen/app_localizations.dart
LF:10
LH:0
end_of_record
''');

    expect(report.total.hit, 9);
    expect(report.total.lines, 10);
    expect(report.total.percent, 90);
    expect(report.files, hasLength(1));
  });

  test('fails a zero-line area and missing critical files', () {
    final report = CoverageReport.parse('''
SF:lib/features/breeds/domain/entities/breed.dart
LF:10
LH:9
end_of_record
''');

    final failures = coverageFailures(report);
    expect(failures, contains(startsWith('data:')));
    expect(failures, contains(startsWith('Missing from LCOV:')));
  });

  test('rejects impossible counts', () {
    expect(
      () => CoverageReport.parse('''
SF:lib/a.dart
LF:2
LH:3
end_of_record
'''),
      throwsFormatException,
    );
  });

  test('rejects a source record without line counts', () {
    expect(
      () => CoverageReport.parse('SF:lib/a.dart\nend_of_record'),
      throwsFormatException,
    );
  });
}
