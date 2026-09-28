import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:test/test.dart';

void main() {
  late _RecordingRepository repository;
  late SearchBreeds searchBreeds;

  setUp(() {
    repository = _RecordingRepository();
    searchBreeds = SearchBreeds(repository);
  });

  test('blank text restores the paginated list', () async {
    final result = await searchBreeds(query: '  ', page: 2);

    expect(result, isA<Success<BreedsPage, BreedsFailure>>());
    expect(repository.listCalls, 1);
    expect(repository.searchCalls, 0);
    expect(repository.lastPage, 2);
    expect(repository.lastLimit, 20);
  });

  test('trims a name before searching', () async {
    final result = await searchBreeds(query: '  siamese  ');

    expect(result, isA<Success<BreedsPage, BreedsFailure>>());
    expect(repository.lastName, 'siamese');
    expect(repository.searchCalls, 1);
    expect(repository.listCalls, 0);
  });

  test('accepts a 30-character name', () async {
    await searchBreeds(query: 'a' * 30);

    expect(repository.searchCalls, 1);
  });

  test(
    'rejects more than 30 characters without calling the repository',
    () async {
      final result = await searchBreeds(query: 'a' * 31);

      expect(result, isA<Failure<BreedsPage, BreedsFailure>>());
      final failure = result as Failure<BreedsPage, BreedsFailure>;
      expect(failure.error, isA<InvalidSearchTermFailure>());
      expect(repository.searchCalls, 0);
      expect(repository.listCalls, 0);
    },
  );
}

final class _RecordingRepository implements BreedsRepository {
  int listCalls = 0;
  int searchCalls = 0;
  int? lastPage;
  int? lastLimit;
  String? lastName;

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) async {
    listCalls++;
    lastPage = page;
    lastLimit = limit;
    return Success(BreedsPage(items: const [], page: page, hasNextPage: false));
  }

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) async {
    searchCalls++;
    lastName = name;
    lastPage = page;
    lastLimit = limit;
    return Success(BreedsPage(items: const [], page: page, hasNextPage: false));
  }

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) {
    throw UnimplementedError('Not used by SearchBreeds tests');
  }
}
