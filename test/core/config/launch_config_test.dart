import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VS Code passes the API define to all Flutter runs', () {
    final settings = jsonDecode(
      File('.vscode/settings.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(
      settings['dart.flutterRunAdditionalArgs'],
      contains('--dart-define-from-file=.secrets/cat_api.json'),
    );

    final source = File('.vscode/launch.json').readAsLinesSync();
    final json = source
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');
    final configurations =
        (jsonDecode(json) as Map<String, dynamic>)['configurations']
            as List<dynamic>;

    for (final flavor in ['development', 'staging', 'production']) {
      final config = configurations.cast<Map<String, dynamic>>().singleWhere(
        (entry) => entry['name'] == 'Launch $flavor',
      );
      final toolArgs = (config['toolArgs'] as List<dynamic>).cast<String>();

      expect(config, isNot(contains('args')));
      expect(config['program'], 'lib/main_$flavor.dart');
      expect(toolArgs, contains('--flavor'));
      expect(toolArgs, contains(flavor));
      expect(
        toolArgs,
        isNot(contains('--dart-define-from-file=.secrets/cat_api.json')),
      );
    }
  });

  test('each Android Studio flavor passes the API define to Flutter', () {
    for (final flavor in ['development', 'staging', 'production']) {
      final configuration = File('.idea/runConfigurations/$flavor.xml')
          .readAsStringSync();

      expect(configuration, contains('name="buildFlavor" value="$flavor"'));
      expect(
        configuration,
        contains(
          'name="additionalArgs" '
          'value="--dart-define-from-file=.secrets/cat_api.json"',
        ),
      );
    }
  });
}
