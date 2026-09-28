import 'package:cat_breeds/core/config/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('development enables engineering diagnostics', () {
      const config = AppConfig.development();

      expect(config.flavor, Flavor.development);
      expect(config.enableVerboseLogging, isTrue);
      expect(config.enableDeveloperTools, isTrue);
      expect(config.apiBaseUrl, 'https://api.thecatapi.com/v1');
      expect(config.apiKey, const String.fromEnvironment('CAT_API_KEY'));
    });

    test('can receive the local API key at compile time', () {
      const expectKey = bool.fromEnvironment('EXPECT_CAT_API_KEY');
      if (expectKey) {
        const config = AppConfig.development();
        expect(config.apiKey, isNotEmpty);
      }
    });

    test('staging has diagnostics but not developer tools', () {
      const config = AppConfig.staging();

      expect(config.flavor, Flavor.staging);
      expect(config.enableVerboseLogging, isTrue);
      expect(config.enableDeveloperTools, isFalse);
    });

    test('production disables engineering-only behavior', () {
      const config = AppConfig.production();

      expect(config.flavor, Flavor.production);
      expect(config.enableVerboseLogging, isFalse);
      expect(config.enableDeveloperTools, isFalse);
    });
  });
}
