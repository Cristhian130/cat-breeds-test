/// Información de raza necesaria para la primera versión de Catbreeds.
///
/// Los campos opcionales pueden faltar en The Cat API, según el registro de la
/// raza y el plan de API. La presentación decide cómo mostrar esas ausencias.
final class Breed {
  new({
    required this.id,
    required this.name,
    this.imageUrl,
    this.origin,
    this.description,
    this.intelligence,
    this.adaptability,
    this.lifeSpan,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be blank');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Cannot be blank');
    }
    _validateRating(intelligence, 'intelligence');
    _validateRating(adaptability, 'adaptability');
  }

  final String id;
  final String name;
  final String? imageUrl;
  final String? origin;
  final String? description;
  final int? intelligence;
  final int? adaptability;
  final String? lifeSpan;

  static void _validateRating(int? value, String name) {
    if (value != null && (value < 1 || value > 5)) {
      throw RangeError.range(value, 1, 5, name);
    }
  }
}
