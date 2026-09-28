import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';

/// Puerto implementado por un adaptador de datos, no depende de HTTP
/// ni Flutter.
abstract interface class BreedsRepository {
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  });

  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  });

  Future<Result<Breed, BreedsFailure>> getBreedById(String id);
}
