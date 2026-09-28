import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/material.dart';

/// Dato único con etiqueta, no conoce el origen de su valor.
class BreedFact extends StatelessWidget {
  const new({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: BrandColors.mutedInk, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: BrandColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
