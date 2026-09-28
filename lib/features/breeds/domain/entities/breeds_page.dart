import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';

/// Página de razas basada en cero, independiente de encabezados HTTP
/// de paginación.
final class BreedsPage {
  new({
    required Iterable<Breed> items,
    required this.page,
    required this.hasNextPage,
  }) : items = List<Breed>.unmodifiable(items) {
    if (page < 0) {
      throw RangeError.value(page, 'page', 'Cannot be negative');
    }
  }

  final List<Breed> items;
  final int page;
  final bool hasNextPage;
}
