import 'package:cat_breeds/features/breeds/data/models/breed_dto.dart';
import 'package:test/test.dart';

void main() {
  test('maps a full API breed to the domain entity', () {
    final dto = BreedDto.fromJson({
      'id': 'abys',
      'name': 'Abyssinian',
      'image': {'url': 'https://cdn2.thecatapi.com/images/cat.jpg'},
      'origin': 'Egypt',
      'description': 'An active cat.',
      'intelligence': 4,
      'adaptability': 3,
      'life_span': '14-17',
      'temperament': 'Curious',
    });
    final breed = dto.toDomain();

    expect(breed.id, 'abys');
    expect(breed.name, 'Abyssinian');
    expect(breed.imageUrl, 'https://cdn2.thecatapi.com/images/cat.jpg');
    expect(breed.origin, 'Egypt');
    expect(breed.description, 'An active cat.');
    expect(breed.intelligence, 4);
    expect(breed.adaptability, 3);
    expect(breed.lifeSpan, '14-17');
  });

  test('accepts a basic-plan response without scores or image', () {
    final breed = BreedDto.fromJson({
      'id': 'siam',
      'name': ' Siamese ',
      'image': null,
      'origin': '',
    }).toDomain();

    expect(breed.name, 'Siamese');
    expect(breed.imageUrl, isNull);
    expect(breed.origin, isNull);
    expect(breed.intelligence, isNull);
    expect(breed.adaptability, isNull);
  });

  test('rejects missing identity and out-of-range ratings', () {
    expect(
      () => BreedDto.fromJson({'id': '', 'name': 'Siamese'}),
      throwsFormatException,
    );
    expect(
      () => BreedDto.fromJson({
        'id': 'siam',
        'name': 'Siamese',
        'intelligence': 0,
      }),
      throwsFormatException,
    );
  });
}
