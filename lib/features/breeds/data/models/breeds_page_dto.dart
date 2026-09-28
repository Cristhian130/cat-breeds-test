import 'package:cat_breeds/features/breeds/data/models/breed_dto.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';

/// Página de API decodificada, se ignoran las razas individuales malformadas.
final class BreedsPageDto {
  new({
    required Iterable<BreedDto> items,
    required this.page,
    required this.hasNextPage,
    this.discardedCount = 0,
  }) : items = List<BreedDto>.unmodifiable(items);

  // Una factoría con nombre requiere el nombre de clase
  // `new.fromJson` no es Dart válido.
  // ignore: unnecessary_type_name_in_constructor
  factory BreedsPageDto.fromJson(
    Object? json, {
    required int page,
    required int limit,
    int? totalCount,
  }) {
    if (json is! List) {
      throw const FormatException('Breeds response must be a JSON array');
    }

    final items = <BreedDto>[];
    var discardedCount = 0;
    for (final value in json) {
      try {
        items.add(BreedDto.fromJson(value));
      } on FormatException {
        // Conserva registros válidos en lugar de perder la página completa.
        discardedCount++;
      }
    }

    if (json.isNotEmpty && items.isEmpty) {
      throw const FormatException('No valid breeds in the response');
    }

    final hasNextPage =
        json.isNotEmpty &&
        (totalCount == null
            ? json.length >= limit
            : (page + 1) * limit < totalCount);

    return BreedsPageDto(
      items: items,
      page: page,
      hasNextPage: hasNextPage,
      discardedCount: discardedCount,
    );
  }

  final List<BreedDto> items;
  final int page;
  final bool hasNextPage;
  final int discardedCount;

  BreedsPage toDomain() => BreedsPage(
    items: items.map((breed) => breed.toDomain()),
    page: page,
    hasNextPage: hasNextPage,
  );
}
