import 'package:cat_breeds/core/design_system/atoms/adaptive_action_button.dart';
import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/presentation/atoms/breed_fact.dart';
import 'package:flutter/material.dart';

/// Resumen de una raza compuesto por átomos visuales, sin dependencia
/// del repositorio.
class BreedCard extends StatelessWidget {
  const new({
    required this.breed,
    required this.originLabel,
    required this.intelligenceLabel,
    required this.notAvailableLabel,
    required this.moreLabel,
    required this.onMore,
    super.key,
  });

  final Breed breed;
  final String originLabel;
  final String intelligenceLabel;
  final String notAvailableLabel;
  final String moreLabel;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: BrandColors.canvas,
      border: Border.all(color: BrandColors.panel, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(BrandSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            breed.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrandColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: BrandSpacing.sm),
          SizedBox(
            height: 190,
            child: BrandPhoto(
              imageUrl: breed.imageUrl,
              semanticLabel: breed.name,
            ),
          ),
          const SizedBox(height: BrandSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final origin = BreedFact(
                label: originLabel,
                value: breed.origin ?? notAvailableLabel,
              );
              final intelligence = BreedFact(
                label: intelligenceLabel,
                value: breed.intelligence?.toString() ?? notAvailableLabel,
              );
              if (constraints.maxWidth < 270 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.2) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    origin,
                    const SizedBox(height: BrandSpacing.sm),
                    intelligence,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: origin),
                  const SizedBox(width: BrandSpacing.sm),
                  Expanded(child: intelligence),
                ],
              );
            },
          ),
          const SizedBox(height: BrandSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AdaptiveActionButton(
              label: moreLabel,
              onPressed: onMore,
              style: AdaptiveActionButtonStyle.text,
            ),
          ),
        ],
      ),
    ),
  );
}
