import 'package:cat_breeds/app/app.dart';
import 'package:cat_breeds/app/router/splash_page.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_card.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_search_field.dart';
import 'package:cat_breeds/features/breeds/presentation/organisms/breed_hero_banner.dart';
import 'package:cat_breeds/features/breeds/presentation/pages/breed_detail_page.dart';
import 'package:cat_breeds/features/breeds/presentation/pages/breeds_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('splash is local and opens the catalog', (tester) async {
      final repository = _FakeBreedsRepository();
      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: repository,
        ),
      );

      expect(find.byType(SplashPage), findsOneWidget);
      expect(repository.listCalls, 0);
      await tester.pump(const Duration(milliseconds: 2899));
      expect(find.byType(SplashPage), findsOneWidget);
      expect(repository.listCalls, 0);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(BreedsCatalogPage), findsOneWidget);
      expect(repository.listCalls, 1);
    });

    testWidgets('matches the reference copy and colors at wide width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(617, 491);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _FakeBreedsRepository();

      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: repository,
        ),
      );
      await _finishSplash(tester);

      expect(find.byType(BreedsCatalogPage), findsOneWidget);
      expect(find.text('Explora razas de gatos'), findsNWidgets(2));
      expect(
        find.text('Busca y explora más de 100 razas de gatos fácilmente.'),
        findsNWidgets(2),
      );
      expect(
        Localizations.localeOf(tester.element(find.byType(BreedsCatalogPage))),
        const Locale('es'),
      );
      expect(repository.listCalls, 1);
      expect(find.byType(BrandPhoto), findsOneWidget);
      final hero = tester.getRect(find.byType(BreedHeroBanner));
      expect(hero.left, closeTo(77, 1));
      expect(hero.top, closeTo(18, 1));
      expect(hero.width, closeTo(520, 1));
      expect(
        Theme.of(tester.element(find.byType(BreedsCatalogPage)))
            .colorScheme
            .primary,
        BrandColors.coral,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacks hero content on a narrow screen', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: _FakeBreedsRepository(),
        ),
      );
      await _finishSplash(tester);

      final titleTop = tester.getTopLeft(
        find.text('Explora razas de gatos').first,
      );
      final photoTop = tester.getTopLeft(find.byType(BrandPhoto));
      expect(photoTop.dy, greaterThan(titleTop.dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('passes the API image URL to the visual atom', (tester) async {
      const apiImageUrl = 'https://cdn2.thecatapi.com/images/cat.jpg';

      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: _FakeBreedsRepository(imageUrl: apiImageUrl),
        ),
      );
      await _finishSplash(tester);

      final photo = tester.widget<BrandPhoto>(find.byType(BrandPhoto));
      expect(photo.imageUrl, apiImageUrl);
    });

    testWidgets('renders cards with optional facts and searches in English', (
      tester,
    ) async {
      final repository = _FakeBreedsRepository();
      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: repository,
        ),
      );
      await _finishSplash(tester);

      await _showSearchField(tester);
      await tester.enterText(find.byType(TextField), 'siamese');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(BreedCard));

      expect(repository.searchCalls, ['siamese']);
      expect(find.text('Siamese'), findsOneWidget);
      expect(find.text('No disponible'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('More opens detail and Back preserves the search', (
      tester,
    ) async {
      final repository = _FakeBreedsRepository();
      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: repository,
        ),
      );
      await _finishSplash(tester);
      await _showSearchField(tester);
      await tester.enterText(find.byType(TextField), 'siamese');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Más…'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Más…'));
      await tester.tap(find.text('Más…'));
      await tester.pumpAndSettle();

      expect(find.byType(BreedDetailPage), findsOneWidget);
      expect(repository.detailIds, ['siam']);
      await tester.tap(find.byTooltip('Volver a las razas'));
      await tester.pumpAndSettle();

      expect(find.byType(BreedsCatalogPage), findsOneWidget);
      expect(find.text('siamese'), findsOneWidget);
      expect(repository.searchCalls, ['siamese']);
    });

    testWidgets('detail retries a missing breed and keeps its photo fixed', (
      tester,
    ) async {
      final repository = _FakeBreedsRepository(
        detailFailuresRemaining: 1,
        detailDescription: List.filled(70, 'A friendly cat.').join(' '),
      );
      await tester.pumpWidget(
        App(
          config: const AppConfig.development(),
          breedsRepository: repository,
        ),
      );
      await _finishSplash(tester);
      await tester.scrollUntilVisible(
        find.text('Más…'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Más…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Más…'));
      await tester.pumpAndSettle();

      expect(find.text('No se encontró esta raza.'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(repository.detailIds, ['abys', 'abys']);

      final photo = find.byType(BrandPhoto);
      final before = tester.getTopLeft(photo);
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(photo), before);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(SplashPage.duration);
  await tester.pumpAndSettle();
}

Future<void> _showSearchField(WidgetTester tester) => tester.scrollUntilVisible(
  find.byType(BreedSearchField),
  250,
  scrollable: find.byType(Scrollable).first,
);

final class _FakeBreedsRepository implements BreedsRepository {
  new({
    this.imageUrl,
    this.detailDescription,
    this.detailFailuresRemaining = 0,
  });

  final String? imageUrl;
  final String? detailDescription;
  int detailFailuresRemaining;
  int listCalls = 0;
  final List<String> searchCalls = [];
  final List<String> detailIds = [];

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) async {
    listCalls++;
    return Success(
      BreedsPage(
        items: [Breed(id: 'abys', name: 'Abyssinian', imageUrl: imageUrl)],
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) async {
    searchCalls.add(name);
    return Success(
      BreedsPage(
        items: [Breed(id: 'siam', name: 'Siamese')],
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) async {
    detailIds.add(id);
    if (detailFailuresRemaining > 0) {
      detailFailuresRemaining--;
      return const Failure(BreedNotFoundFailure());
    }
    return Success(
      Breed(
        id: id,
        name: 'Abyssinian',
        imageUrl: imageUrl,
        description: detailDescription,
      ),
    );
  }
}
