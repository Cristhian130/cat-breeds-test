import 'package:cat_breeds/core/design_system/atoms/accent_bar.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_typography.dart';
import 'package:flutter/material.dart';

/// Acento, encabezado y texto de apoyo del hero de referencia.
class BreedHeroCopy extends StatelessWidget {
  const new({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AccentBar(),
      const SizedBox(width: BrandSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: BrandTypography.heroTitle),
            const SizedBox(height: BrandSpacing.xs),
            Text(subtitle, style: BrandTypography.heroSubtitle),
          ],
        ),
      ),
    ],
  );
}
