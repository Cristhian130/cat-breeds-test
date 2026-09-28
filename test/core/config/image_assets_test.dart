import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('splash and placeholder images are bundled as Flutter assets', () async {
    const paths = [
      'assets/images/branding/splash_screen.jpg',
      'assets/images/placeholders/placeholder.jpg',
    ];

    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0));
    }
  });

  test('Poppins Regular and Bold are bundled locally', () async {
    const paths = [
      'assets/fonts/poppins/Poppins-Regular.ttf',
      'assets/fonts/poppins/Poppins-Bold.ttf',
    ];

    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}
