import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_breakpoints.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_hero_copy.dart';
import 'package:flutter/material.dart';

/// Hero responsive que conserva el diseño dividido de la referencia
/// cuando es posible.
class BreedHeroBanner extends StatelessWidget {
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
    builder: (context, constraints) {
      final sideBySide =
          constraints.maxWidth >= BrandBreakpoints.heroSideBySide &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.2;

      return ColoredBox(
        color: BrandColors.panel,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sideBySide ? 38 : BrandSpacing.lg,
            vertical: sideBySide ? 39 : BrandSpacing.lg,
          ),
          child: sideBySide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: BrandSpacing.sm),
                        child: BreedHeroCopy(title: title, subtitle: subtitle),
                      ),
                    ),
                    const SizedBox(width: BrandSpacing.lg),
                    SizedBox(
                      width: 215,
                      height: 269,
                      child: BrandPhoto(
                        imageUrl: imageUrl,
                        semanticLabel: imageLabel,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BreedHeroCopy(title: title, subtitle: subtitle),
                    const SizedBox(height: BrandSpacing.lg),
                    SizedBox(
                      height: 260,
                      child: BrandPhoto(
                        imageUrl: imageUrl,
                        semanticLabel: imageLabel,
                      ),
                    ),
                  ],
                ),
        ),
      );
    },
  );
}
