import 'package:cat_breeds/features/breeds/data/models/breeds_page_dto.dart';
import 'package:test/test.dart';

void main() {
  test('uses the total count to determine whether another page exists', () {
    final result = BreedsPageDto.fromJson(
      [
        {'id': 'abys', 'name': 'Abyssinian'},
        {'id': 'beng', 'name': 'Bengal'},
      ],
      page: 0,
      limit: 2,
      totalCount: 3,
    ).toDomain();

    expect(result.items, hasLength(2));
    expect(result.hasNextPage, isTrue);
    expect(result.page, 0);
  });

  test('falls back to the raw page size when headers are absent', () {
    final fullPage = BreedsPageDto.fromJson(
      [
        {'id': 'abys', 'name': 'Abyssinian'},
        {'id': 'beng', 'name': 'Bengal'},
      ],
      page: 0,
      limit: 2,
    );
    final shortPage = BreedsPageDto.fromJson(
      [
        {'id': 'siam', 'name': 'Siamese'},
      ],
      page: 1,
      limit: 2,
    );

    expect(fullPage.hasNextPage, isTrue);
    expect(shortPage.hasNextPage, isFalse);
  });

  test('skips malformed records while preserving valid ones', () {
    final result = BreedsPageDto.fromJson(
      [
        {'id': '', 'name': 'Invalid'},
        {'id': 'siam', 'name': 'Siamese'},
      ],
      page: 0,
      limit: 2,
    );

    expect(result.items, hasLength(1));
    expect(result.items.single.id, 'siam');
    expect(result.discardedCount, 1);
  });

  test('rejects an entirely malformed non-empty page', () {
    expect(
      () => BreedsPageDto.fromJson(
        [
          {'id': '', 'name': 'Invalid'},
        ],
        page: 0,
        limit: 20,
      ),
      throwsFormatException,
    );
  });

  test('keeps an empty response distinct from malformed data', () {
    final result = BreedsPageDto.fromJson([], page: 0, limit: 20);

    expect(result.items, isEmpty);
    expect(result.hasNextPage, isFalse);
  });
}
