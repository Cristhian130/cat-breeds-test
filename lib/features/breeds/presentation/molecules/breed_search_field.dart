import 'package:cat_breeds/core/design_system/molecules/adaptive_search_field.dart';
import 'package:flutter/material.dart';

/// Solo recibe texto: el BLoC controla el tiempo de búsqueda
/// y el estado de red.
class BreedSearchField extends StatelessWidget {
  const new({required this.hint, required this.onChanged, super.key});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) =>
      AdaptiveSearchField(hint: hint, onChanged: onChanged);
}
