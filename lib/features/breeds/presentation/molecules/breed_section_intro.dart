import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_typography.dart';
import 'package:flutter/material.dart';

/// Título centrado y texto de apoyo debajo del panel hero.
class BreedSectionIntro extends StatelessWidget {
  const new({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: BrandTypography.sectionTitle,
      ),
      const SizedBox(height: BrandSpacing.lg),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: BrandTypography.sectionSubtitle,
      ),
    ],
  );
}
