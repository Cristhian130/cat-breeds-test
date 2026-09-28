import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:test/test.dart';

void main() {
  test('BreedsPage is insulated from changes to the source list', () {
    final source = [Breed(id: 'siam', name: 'Siamese')];
    final result = BreedsPage(items: source, page: 0, hasNextPage: true);

    source.clear();

    expect(result.items, hasLength(1));
    expect(result.page, 0);
    expect(result.hasNextPage, isTrue);
    expect(result.items.clear, throwsUnsupportedError);
  });

  test('BreedsPage rejects a negative page index', () {
    expect(
      () => BreedsPage(items: const [], page: -1, hasNextPage: false),
      throwsRangeError,
    );
  });
}
