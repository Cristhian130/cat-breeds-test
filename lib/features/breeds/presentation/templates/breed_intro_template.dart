import 'package:cat_breeds/core/design_system/tokens/brand_breakpoints.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_section_intro.dart';
import 'package:cat_breeds/features/breeds/presentation/organisms/breed_hero_banner.dart';
import 'package:flutter/material.dart';

/// Estructura de página para el contenido introductorio inspirado
/// en la referencia.
class BreedIntroTemplate extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.imageLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final String imageLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: const EdgeInsets.fromLTRB(
        BrandSpacing.md,
        18,
        BrandSpacing.md,
        BrandSpacing.lg,
      ),
      child: Align(
        alignment: constraints.maxWidth < BrandBreakpoints.centeredCanvas
            ? Alignment.centerRight
            : Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: BrandBreakpoints.contentMaxWidth,
          ),
          child: Column(
            children: [
              BreedHeroBanner(
                title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                imageLabel: imageLabel,
              ),
              const SizedBox(height: BrandSpacing.sm),
              BreedSectionIntro(title: title, subtitle: subtitle),
            ],
          ),
        ),
      ),
    ),
  );
}
