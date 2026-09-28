import 'package:cat_breeds/core/design_system/atoms/adaptive_action_button.dart';
import 'package:cat_breeds/core/design_system/atoms/adaptive_activity_indicator.dart';
import 'package:cat_breeds/core/design_system/molecules/adaptive_search_field.dart';
import 'package:cat_breeds/core/design_system/templates/adaptive_page_scaffold.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses Cupertino controls on iOS', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: _screen(),
      ),
    );

    expect(find.byType(cupertino.CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(cupertino.CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(cupertino.CupertinoTextField), findsOneWidget);
    expect(find.byType(cupertino.CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(cupertino.CupertinoButton), findsWidgets);
  });

  testWidgets('uses Material controls on Android', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: _screen(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}

Widget _screen() => AdaptivePageScaffold(
  title: 'Abyssinian',
  backLabel: 'Back',
  onBack: () {},
  body: Column(
    children: [
      AdaptiveSearchField(hint: 'Busca razas en inglés', onChanged: (_) {}),
      const AdaptiveActivityIndicator(),
      AdaptiveActionButton(label: 'Reintentar', onPressed: () {}),
    ],
  ),
);
