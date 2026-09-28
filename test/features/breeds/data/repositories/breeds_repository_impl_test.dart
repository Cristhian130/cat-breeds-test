import 'package:cat_breeds/features/breeds/data/models/breed_dto.dart';
import 'package:cat_breeds/features/breeds/data/models/breeds_page_dto.dart';
import 'package:cat_breeds/features/breeds/data/repositories/breeds_repository_impl.dart';
import 'package:cat_breeds/features/breeds/data/sources/breeds_remote_data_source.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late _StubRemote remote;
  late BreedsRepositoryImpl repository;

  setUp(() {
    remote = _StubRemote();
    repository = BreedsRepositoryImpl(remote);
  });

  test('maps a successful page to domain breeds', () async {
    final result = await repository.getBreeds(page: 0, limit: 20);

    expect(result, isA<Success<BreedsPage, BreedsFailure>>());
    final page = (result as Success<BreedsPage, BreedsFailure>).value;
    expect(page.items.single.name, 'Siamese');
    expect(page.items.single.intelligence, isNull);
  });

  test('maps a successful detail to a domain breed', () async {
    final result = await repository.getBreedById('siam');

    expect(result, isA<Success<Breed, BreedsFailure>>());
    expect((result as Success<Breed, BreedsFailure>).value.id, 'siam');
  });

  test('maps network timeout to ConnectionFailure', () async {
    remote.error = DioException(
      requestOptions: RequestOptions(path: 'breeds'),
      type: DioExceptionType.connectionTimeout,
    );

    final result = await repository.getBreeds(page: 0, limit: 20);

    expect(_pageFailure(result), isA<ConnectionFailure>());
  });

  test('maps HTTP 401 to AccessDeniedFailure', () async {
    remote.error = _httpError(401);

    final result = await repository.getBreeds(page: 0, limit: 20);

    expect(_pageFailure(result), isA<AccessDeniedFailure>());
  });

  test('maps HTTP 429 to RateLimitFailure', () async {
    remote.error = _httpError(429);

    final result = await repository.searchBreeds(
      name: 'siamese',
      page: 0,
      limit: 20,
    );

    expect(_pageFailure(result), isA<RateLimitFailure>());
  });

  test('maps detail HTTP 404 to BreedNotFoundFailure', () async {
    remote.error = _httpError(404);

    final result = await repository.getBreedById('missing');

    expect(result, isA<Failure<Breed, BreedsFailure>>());
    expect(
      (result as Failure<Breed, BreedsFailure>).error,
      isA<BreedNotFoundFailure>(),
    );
  });

  test('maps malformed data to InvalidBreedDataFailure', () async {
    remote.error = const FormatException('Invalid JSON');

    final result = await repository.getBreeds(page: 0, limit: 20);

    expect(_pageFailure(result), isA<InvalidBreedDataFailure>());
  });

  test('maps unclassified exceptions to UnexpectedBreedsFailure', () async {
    remote.error = Exception('Unexpected');

    final result = await repository.getBreeds(page: 0, limit: 20);

    expect(_pageFailure(result), isA<UnexpectedBreedsFailure>());
  });
}

BreedsFailure _pageFailure(Result<BreedsPage, BreedsFailure> result) =>
    (result as Failure<BreedsPage, BreedsFailure>).error;

DioException _httpError(int statusCode) {
  final options = RequestOptions(path: 'breeds');
  return DioException(
    requestOptions: options,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
    ),
    type: DioExceptionType.badResponse,
  );
}

final class _StubRemote implements BreedsRemoteDataSource {
  Exception? error;

  @override
  Future<BreedsPageDto> getBreeds({
    required int page,
    required int limit,
  }) async {
    _throwIfConfigured();
    return BreedsPageDto(
      items: const [BreedDto(id: 'siam', name: 'Siamese')],
      page: page,
      hasNextPage: false,
    );
  }

  @override
  Future<BreedsPageDto> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) => getBreeds(page: page, limit: limit);

  @override
  Future<BreedDto> getBreedById(String id) async {
    _throwIfConfigured();
    return BreedDto(id: id, name: 'Siamese');
  }

  void _throwIfConfigured() {
    if (error != null) throw error!;
  }
}
