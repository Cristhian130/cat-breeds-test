// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:cat_breeds/app/app.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:cat_breeds/counter/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App(config: AppConfig.development()));
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
