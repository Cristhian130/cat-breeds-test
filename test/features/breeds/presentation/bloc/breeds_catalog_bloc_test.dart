import 'dart:async';

import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_bloc.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BreedsCatalogBloc', () {
    test('loads the first page and exposes pagination', () async {
      final repository = _Repository(
        (query, page) async =>
            _page(page, [Breed(id: 'abys', name: 'Abyssinian')], hasMore: true),
      );
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      final ready = _next(bloc, CatalogStatus.success);
      bloc.add(const CatalogStarted());
      final state = await ready;

      expect(repository.calls, [(query: '', page: 0)]);
      expect(state.breeds.single.name, 'Abyssinian');
      expect(state.nextPage, 1);
      expect(state.hasMore, isTrue);
    });

    test('keeps an empty result separate from a transport error', () async {
      final repository = _Repository((query, page) async => _page(page, []));
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      final empty = _next(bloc, CatalogStatus.empty);
      bloc.add(const CatalogStarted());
      expect((await empty).failure, isNull);
    });

    test('retries a failed first page', () async {
      var calls = 0;
      final repository = _Repository((query, page) async {
        calls++;
        return calls == 1
            ? const Failure<BreedsPage, BreedsFailure>(ConnectionFailure())
            : _page(page, [Breed(id: 'abys', name: 'Abyssinian')]);
      });
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      final failed = _next(bloc, CatalogStatus.failure);
      bloc.add(const CatalogStarted());
      expect((await failed).failure, isA<ConnectionFailure>());

      final ready = _next(bloc, CatalogStatus.success);
      bloc.add(const CatalogRetryRequested());
      expect((await ready).breeds, hasLength(1));
      expect(calls, 2);
    });

    test('debounces rapid typing and only searches the last query', () async {
      final repository = _Repository((query, page) async => _page(page, []));
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      bloc
        ..add(const CatalogQueryChanged('si'))
        ..add(const CatalogQueryChanged('siamese'));
      final empty = _next(bloc, CatalogStatus.empty);
      expect((await empty).query, 'siamese');
      expect(repository.calls, [(query: 'siamese', page: 0)]);
    });

    test('ignores an old response after a newer query', () async {
      final oldRequest = Completer<Result<BreedsPage, BreedsFailure>>();
      final repository = _Repository(
        (query, page) => query.isEmpty
            ? oldRequest.future
            : Future.value(_page(page, [Breed(id: 'siam', name: 'Siamese')])),
      );
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      bloc.add(const CatalogStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final current = _next(bloc, CatalogStatus.success);
      bloc.add(const CatalogQueryChanged('siamese'));
      expect((await current).breeds.single.name, 'Siamese');

      oldRequest.complete(_page(0, [Breed(id: 'abys', name: 'Abyssinian')]));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.breeds.single.name, 'Siamese');
    });

    test('deduplicates pages and retries a failed next page', () async {
      var pageOneCalls = 0;
      final repository = _Repository((query, page) async {
        if (page == 0) {
          return _page(0, [
            Breed(id: 'abys', name: 'Abyssinian'),
          ], hasMore: true);
        }
        pageOneCalls++;
        if (pageOneCalls == 1) {
          return const Failure<BreedsPage, BreedsFailure>(ConnectionFailure());
        }
        return _page(1, [
          Breed(id: 'abys', name: 'Abyssinian'),
          Breed(id: 'siam', name: 'Siamese'),
        ]);
      });
      final bloc = BreedsCatalogBloc(SearchBreeds(repository));
      addTearDown(bloc.close);

      final first = _next(bloc, CatalogStatus.success);
      bloc.add(const CatalogStarted());
      await first;

      final failedPage = bloc.stream.firstWhere(
        (state) => state.loadMoreFailure != null,
      );
      bloc.add(const CatalogLoadMoreRequested());
      expect((await failedPage).breeds, hasLength(1));

      final retried = bloc.stream.firstWhere(
        (state) => state.breeds.length == 2,
      );
      bloc.add(const CatalogRetryRequested());
      final state = await retried;
      expect(state.breeds.map((breed) => breed.id), ['abys', 'siam']);
      expect(state.hasMore, isFalse);
      expect(pageOneCalls, 2);
    });
  });
}

Future<BreedsCatalogState> _next(
  BreedsCatalogBloc bloc,
  CatalogStatus status,
) => bloc.stream.firstWhere((state) => state.status == status);

Result<BreedsPage, BreedsFailure> _page(
  int page,
  List<Breed> breeds, {
  bool hasMore = false,
}) => Success(BreedsPage(items: breeds, page: page, hasNextPage: hasMore));

final class _Repository implements BreedsRepository {
  new(this._answer);

  final Future<Result<BreedsPage, BreedsFailure>> Function(String, int) _answer;
  final List<({String query, int page})> calls = [];

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) {
    calls.add((query: '', page: page));
    return _answer('', page);
  }

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) {
    calls.add((query: name, page: page));
    return _answer(name, page);
  }

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) =>
      throw UnimplementedError();
}
