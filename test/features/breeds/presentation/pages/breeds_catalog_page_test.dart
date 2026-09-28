import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/presentation/pages/breeds_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  for (final (failure, message) in [
    (const ConnectionFailure(), 'Comprueba la conexión e inténtalo de nuevo.'),
    (
      const AccessDeniedFailure(),
      'La API rechazó el acceso. Comprueba la clave.',
    ),
    (
      const RateLimitFailure(),
      'Se alcanzó el límite de peticiones. Inténtalo más tarde.',
    ),
    (
      const UnexpectedBreedsFailure(),
      'No pudimos cargar las razas. Inténtalo de nuevo.',
    ),
  ]) {
    testWidgets('shows ${failure.runtimeType} and can retry', (tester) async {
      final repository = _CatalogRepository(firstFailure: failure);
      await tester.pumpApp(BreedsCatalogPage(repository: repository));
      await tester.pumpAndSettle();
      await _showFeedback(tester);

      expect(find.text(message), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(repository.listCalls, 2);
      expect(find.text('Abyssinian'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('distinguishes an empty catalog from an empty search', (
    tester,
  ) async {
    final repository = _CatalogRepository(empty: true);
    await tester.pumpApp(BreedsCatalogPage(repository: repository));
    await tester.pumpAndSettle();
    await _showFeedback(tester);
    expect(find.text('Aún no hay razas disponibles.'), findsOneWidget);

    await _showSearchField(tester);
    await tester.enterText(find.byType(TextField), 'unknown');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Ninguna raza coincide con la búsqueda.'), findsOneWidget);
    expect(repository.searchCalls, ['unknown']);
  });

  testWidgets('rejects an overlong search without an API request', (
    tester,
  ) async {
    final repository = _CatalogRepository();
    await tester.pumpApp(BreedsCatalogPage(repository: repository));
    await tester.pumpAndSettle();

    await _showSearchField(tester);
    await tester.enterText(find.byType(TextField), 'a' * 31);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await _showFeedback(tester);

    expect(find.text('Busca con 30 caracteres o menos.'), findsOneWidget);
    expect(repository.searchCalls, isEmpty);
  });
}

Future<void> _showFeedback(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
  await tester.pumpAndSettle();
}

Future<void> _showSearchField(WidgetTester tester) => tester.scrollUntilVisible(
  find.byType(TextField),
  250,
  scrollable: find.byType(Scrollable).first,
);

final class _CatalogRepository implements BreedsRepository {
  new({this.firstFailure, this.empty = false});

  final BreedsFailure? firstFailure;
  final bool empty;
  int listCalls = 0;
  final List<String> searchCalls = [];

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) async {
    listCalls++;
    if (listCalls == 1 && firstFailure != null) {
      return Failure(firstFailure!);
    }
    return Success(
      BreedsPage(
        items: empty ? const [] : [Breed(id: 'abys', name: 'Abyssinian')],
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
    return Success(BreedsPage(items: const [], page: page, hasNextPage: false));
  }

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) =>
      throw UnimplementedError();
}
