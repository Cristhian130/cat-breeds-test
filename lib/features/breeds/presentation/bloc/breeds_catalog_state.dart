// Los constructores con nombre no pueden usar la sintaxis abreviada `new`
// de Dart.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';

enum CatalogStatus { initial, loading, success, empty, failure }

/// Instantánea del catálogo, incluido su estado independiente de paginación.
final class BreedsCatalogState {
  BreedsCatalogState._({
    required this.status,
    required this.query,
    this.heroImageUrl,
    Iterable<Breed> breeds = const [],
    this.hasMore = false,
    this.nextPage = 0,
    this.failure,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  }) : breeds = List<Breed>.unmodifiable(breeds);

  factory BreedsCatalogState.initial() =>
      BreedsCatalogState._(status: CatalogStatus.initial, query: '');

  factory BreedsCatalogState.loading(String query, {String? heroImageUrl}) =>
      BreedsCatalogState._(
        status: CatalogStatus.loading,
        query: query,
        heroImageUrl: heroImageUrl,
      );

  factory BreedsCatalogState.empty(String query, {String? heroImageUrl}) =>
      BreedsCatalogState._(
        status: CatalogStatus.empty,
        query: query,
        heroImageUrl: heroImageUrl,
      );

  factory BreedsCatalogState.failed(
    String query,
    BreedsFailure failure, {
    String? heroImageUrl,
  }) => BreedsCatalogState._(
    status: CatalogStatus.failure,
    query: query,
    failure: failure,
    heroImageUrl: heroImageUrl,
  );

  factory BreedsCatalogState.ready({
    required String query,
    required Iterable<Breed> breeds,
    required bool hasMore,
    required int nextPage,
    String? heroImageUrl,
    bool isLoadingMore = false,
    BreedsFailure? loadMoreFailure,
  }) => BreedsCatalogState._(
    status: CatalogStatus.success,
    query: query,
    heroImageUrl: heroImageUrl,
    breeds: breeds,
    hasMore: hasMore,
    nextPage: nextPage,
    isLoadingMore: isLoadingMore,
    loadMoreFailure: loadMoreFailure,
  );

  final CatalogStatus status;
  final String query;
  final String? heroImageUrl;
  final List<Breed> breeds;
  final bool hasMore;
  final int nextPage;
  final BreedsFailure? failure;
  final bool isLoadingMore;
  final BreedsFailure? loadMoreFailure;
}
