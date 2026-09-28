import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:test/test.dart';

void main() {
  group('Breed', () {
    test('keeps optional fields absent without inventing values', () {
      final breed = Breed(id: 'siam', name: 'Siamese');

      expect(breed.imageUrl, isNull);
      expect(breed.origin, isNull);
      expect(breed.description, isNull);
      expect(breed.intelligence, isNull);
      expect(breed.adaptability, isNull);
      expect(breed.lifeSpan, isNull);
    });

    test('requires a non-blank id and name', () {
      expect(() => Breed(id: ' ', name: 'Siamese'), throwsArgumentError);
      expect(() => Breed(id: 'siam', name: ' '), throwsArgumentError);
    });

    test('accepts ratings from 1 to 5 only', () {
      expect(
        Breed(id: 'siam', name: 'Siamese', intelligence: 1).intelligence,
        1,
      );
      expect(
        Breed(id: 'siam', name: 'Siamese', adaptability: 5).adaptability,
        5,
      );
      expect(
        () => Breed(id: 'siam', name: 'Siamese', intelligence: 0),
        throwsRangeError,
      );
      expect(
        () => Breed(id: 'siam', name: 'Siamese', adaptability: 6),
        throwsRangeError,
      );
    });
  });
}
