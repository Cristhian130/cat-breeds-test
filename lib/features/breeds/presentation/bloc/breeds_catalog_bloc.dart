import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_state.dart';

/// Coordina la primera carga, la búsqueda en inglés con debounce
/// y los resultados paginados.
final class BreedsCatalogBloc
    extends Bloc<BreedsCatalogEvent, BreedsCatalogState> {
  new(this._searchBreeds) : super(BreedsCatalogState.initial()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogQueryChanged>(_onQueryChanged);
    on<CatalogSearchDue>(_onSearchDue);
    on<CatalogLoadMoreRequested>(_onLoadMore);
    on<CatalogRetryRequested>(_onRetry);
  }

  static const searchDelay = Duration(milliseconds: 350);

  final SearchBreeds _searchBreeds;
  Timer? _searchTimer;
  int _revision = 0;

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<BreedsCatalogState> emit,
  ) async {
    _searchTimer?.cancel();
    final revision = ++_revision;
    final query = state.query;
    emit(BreedsCatalogState.loading(query, heroImageUrl: state.heroImageUrl));
    await _loadFirst(query, revision, emit);
  }

  void _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<BreedsCatalogState> emit,
  ) {
    _searchTimer?.cancel();
    final revision = ++_revision;
    emit(
      BreedsCatalogState.loading(event.query, heroImageUrl: state.heroImageUrl),
    );
    if (event.query.trim().isEmpty) {
      add(CatalogSearchDue(revision));
    } else {
      _searchTimer = Timer(searchDelay, () {
        if (!isClosed) add(CatalogSearchDue(revision));
      });
    }
  }

  Future<void> _onSearchDue(
    CatalogSearchDue event,
    Emitter<BreedsCatalogState> emit,
  ) async {
    if (event.revision != _revision) return;
    await _loadFirst(state.query, event.revision, emit);
  }

  Future<void> _loadFirst(
    String query,
    int revision,
    Emitter<BreedsCatalogState> emit,
  ) async {
    final result = await _searchBreeds(query: query);
    if (revision != _revision || emit.isDone) return;
    switch (result) {
      case Success<BreedsPage, BreedsFailure>(:final value):
        emit(
          value.items.isEmpty
              ? BreedsCatalogState.empty(
                  query,
                  heroImageUrl: state.heroImageUrl,
                )
              : BreedsCatalogState.ready(
                  query: query,
                  breeds: value.items,
                  hasMore: value.hasNextPage,
                  nextPage: value.page + 1,
                  heroImageUrl:
                      state.heroImageUrl ?? value.items.first.imageUrl,
                ),
        );
      case Failure<BreedsPage, BreedsFailure>(:final error):
        emit(
          BreedsCatalogState.failed(
            query,
            error,
            heroImageUrl: state.heroImageUrl,
          ),
        );
    }
  }

  Future<void> _onLoadMore(
    CatalogLoadMoreRequested event,
    Emitter<BreedsCatalogState> emit,
  ) async {
    final current = state;
    if (current.status != CatalogStatus.success ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    final revision = _revision;
    emit(
      BreedsCatalogState.ready(
        query: current.query,
        breeds: current.breeds,
        hasMore: current.hasMore,
        nextPage: current.nextPage,
        heroImageUrl: current.heroImageUrl,
        isLoadingMore: true,
      ),
    );
    final result = await _searchBreeds(
      query: current.query,
      page: current.nextPage,
    );
    if (revision != _revision || emit.isDone) return;

    switch (result) {
      case Success<BreedsPage, BreedsFailure>(:final value):
        final seen = current.breeds.map((breed) => breed.id).toSet();
        final unique = value.items.where((breed) => seen.add(breed.id));
        final additions = List<Breed>.of(unique);
        emit(
          BreedsCatalogState.ready(
            query: current.query,
            breeds: [...current.breeds, ...additions],
            hasMore: value.hasNextPage && additions.isNotEmpty,
            nextPage: current.nextPage + 1,
            heroImageUrl: current.heroImageUrl,
          ),
        );
      case Failure<BreedsPage, BreedsFailure>(:final error):
        emit(
          BreedsCatalogState.ready(
            query: current.query,
            breeds: current.breeds,
            hasMore: current.hasMore,
            nextPage: current.nextPage,
            heroImageUrl: current.heroImageUrl,
            loadMoreFailure: error,
          ),
        );
    }
  }

  void _onRetry(CatalogRetryRequested event, Emitter<BreedsCatalogState> emit) {
    if (state.loadMoreFailure != null) {
      add(const CatalogLoadMoreRequested());
    } else if (state.status == CatalogStatus.failure) {
      add(const CatalogStarted());
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
