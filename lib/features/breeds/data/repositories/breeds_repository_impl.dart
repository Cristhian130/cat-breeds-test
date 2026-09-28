import 'package:cat_breeds/features/breeds/data/sources/breeds_remote_data_source.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:dio/dio.dart';

/// Convierte DTOs y errores de transporte de API en el contrato puro
/// del dominio.
final class BreedsRepositoryImpl implements BreedsRepository {
  const new(this._remote);

  final BreedsRemoteDataSource _remote;

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) => _guard(
    () async => (await _remote.getBreeds(page: page, limit: limit)).toDomain(),
  );

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) => _guard(
    () async => (await _remote.searchBreeds(
      name: name,
      page: page,
      limit: limit,
    )).toDomain(),
  );

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) => _guard(
    () async => (await _remote.getBreedById(id)).toDomain(),
    isDetail: true,
  );

  Future<Result<T, BreedsFailure>> _guard<T>(
    Future<T> Function() operation, {
    bool isDetail = false,
  }) async {
    try {
      return Success<T, BreedsFailure>(await operation());
    } on DioException catch (error) {
      return Failure<T, BreedsFailure>(_mapDioFailure(error, isDetail));
    } on FormatException {
      return Failure<T, BreedsFailure>(const InvalidBreedDataFailure());
    } on Exception {
      return Failure<T, BreedsFailure>(const UnexpectedBreedsFailure());
    }
  }

  static BreedsFailure _mapDioFailure(DioException error, bool isDetail) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const ConnectionFailure();
    }

    final status = error.response?.statusCode;
    return switch (status) {
      401 || 403 => const AccessDeniedFailure(),
      404 when isDetail => const BreedNotFoundFailure(),
      408 || 504 => const ConnectionFailure(),
      429 => const RateLimitFailure(),
      _ => const UnexpectedBreedsFailure(),
    };
  }
}
