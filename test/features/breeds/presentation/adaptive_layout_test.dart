import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:cat_breeds/core/design_system/templates/brand_splash_template.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_theme.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_card.dart';
import 'package:cat_breeds/features/breeds/presentation/organisms/breeds_catalog_collection.dart';
import 'package:cat_breeds/features/breeds/presentation/templates/breed_detail_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (width, height, columns) in [
    (320.0, 700.0, 1),
    (800.0, 700.0, 2),
    (1440.0, 900.0, 2),
  ]) {
    testWidgets('catalog adapts to ${width.toInt()} px', (tester) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_catalog());
      await tester.pumpAndSettle();

      expect(
        find.byType(SliverGrid),
        columns == 2 ? findsOneWidget : findsNothing,
      );
      final card = tester.getRect(find.byType(BreedCard));
      if (width == 320) {
        expect(card.left, 20);
        expect(card.width, 280);
      } else if (width == 1440) {
        expect(card.left, closeTo(290, 1));
        expect(card.width, closeTo(420, 1));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text uses a flexible single-column card', (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_catalog(textScale: 1.8));
    await tester.pumpAndSettle();

    expect(find.byType(SliverGrid), findsNothing);
    expect(tester.getRect(find.byType(BreedCard)).width, 520);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two-column cards fit at the largest grid text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_catalog(textScale: 1.2));
    await tester.pumpAndSettle();

    expect(find.byType(SliverGrid), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short detail viewport leaves room for scrollable information', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(568, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: BrandTheme.light,
        home: BreedDetailTemplate(
          title: 'Abyssinian',
          backLabel: 'Back',
          onBack: () {},
          showPhoto: true,
          content: ListView(
            children: List.generate(20, (index) => Text('Fact $index')),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(BrandPhoto)).height, lessThan(80));
    expect(tester.getSize(find.byType(ListView)).height, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash image covers the entire short landscape viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(568, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: BrandTheme.light,
        home: const BrandSplashTemplate(title: 'Catbreeds'),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
    expect(
      tester.getRect(find.byType(Image)),
      const Rect.fromLTWH(0, 0, 568, 240),
    );
    final title = tester.widget<Text>(find.text('Catbreeds'));
    expect(title.style?.color, BrandColors.splashText);
    expect(tester.getCenter(find.text('Catbreeds')), const Offset(284, 120));
    expect(tester.takeException(), isNull);
  });
}

Widget _catalog({double textScale = 1}) => MaterialApp(
  theme: BrandTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: CustomScrollView(
      slivers: [
        BreedsCatalogCollection(
          breeds: [
            Breed(
              id: 'abys',
              name: 'Abyssinian mountain cat with a long name',
              origin: 'Ethiopia',
            ),
          ],
          originLabel: 'País de origen',
          intelligenceLabel: 'Inteligencia',
          notAvailableLabel: 'No disponible',
          moreLabel: 'Más…',
          onBreedSelected: (_) {},
        ),
      ],
    ),
  ),
);
