import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';

/// Aplica reglas de búsqueda antes de delegar en el repositorio.
final class SearchBreeds {
  const new(this._repository);

  final BreedsRepository _repository;

  Future<Result<BreedsPage, BreedsFailure>> call({
    required String query,
    int page = 0,
    int limit = 20,
  }) {
    final name = query.trim();

    if (name.isEmpty) {
      return _repository.getBreeds(page: page, limit: limit);
    }

    if (name.runes.length > 30) {
      return Future.value(
        const Failure<BreedsPage, BreedsFailure>(InvalidSearchTermFailure()),
      );
    }

    return _repository.searchBreeds(name: name, page: page, limit: limit);
  }
}
