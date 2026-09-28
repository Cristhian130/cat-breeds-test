import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';

/// Solo los campos de API usados por la primera versión de la aplicación.
final class BreedDto {
  const new({
    required this.id,
    required this.name,
    this.imageUrl,
    this.origin,
    this.description,
    this.intelligence,
    this.adaptability,
    this.lifeSpan,
  });

  // Una factoría con nombre requiere el nombre de clase
  // `new.fromJson` no es Dart válido.
  // ignore: unnecessary_type_name_in_constructor
  factory BreedDto.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Breed must be a JSON object');
    }

    final id = _requiredText(json['id'], 'id');
    final name = _requiredText(json['name'], 'name');
    final Object? image = json['image'];
    final Map<String, dynamic>? imageJson;
    if (image == null) {
      imageJson = null;
    } else if (image is Map<String, dynamic>) {
      imageJson = image;
    } else {
      throw const FormatException('image must be a JSON object');
    }

    return BreedDto(
      id: id,
      name: name,
      imageUrl: imageJson == null
          ? null
          : _optionalText(imageJson['url'], 'image.url'),
      origin: _optionalText(json['origin'], 'origin'),
      description: _optionalText(json['description'], 'description'),
      intelligence: _optionalRating(json['intelligence'], 'intelligence'),
      adaptability: _optionalRating(json['adaptability'], 'adaptability'),
      lifeSpan: _optionalText(json['life_span'], 'life_span'),
    );
  }

  final String id;
  final String name;
  final String? imageUrl;
  final String? origin;
  final String? description;
  final int? intelligence;
  final int? adaptability;
  final String? lifeSpan;

  Breed toDomain() => Breed(
    id: id,
    name: name,
    imageUrl: imageUrl,
    origin: origin,
    description: description,
    intelligence: intelligence,
    adaptability: adaptability,
    lifeSpan: lifeSpan,
  );

  static String _requiredText(Object? value, String field) {
    final text = _optionalText(value, field);
    if (text == null) {
      throw FormatException('$field is required');
    }
    return text;
  }

  static String? _optionalText(Object? value, String field) {
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$field must be a string');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _optionalRating(Object? value, String field) {
    if (value == null) return null;
    if (value is! int || value < 1 || value > 5) {
      throw FormatException('$field must be an integer from 1 to 5');
    }
    return value;
  }
}
