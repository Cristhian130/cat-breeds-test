import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/presentation/atoms/breed_fact.dart';
import 'package:flutter/material.dart';

/// Parte textual desplazable del detalle, la foto permanece fuera de ella.
class BreedDetailInformation extends StatelessWidget {
  const new({
    required this.breed,
    required this.descriptionLabel,
    required this.descriptionMissing,
    required this.originLabel,
    required this.intelligenceLabel,
    required this.adaptabilityLabel,
    required this.lifeSpanLabel,
    required this.yearsLabel,
    required this.notAvailableLabel,
    super.key,
  });

  final Breed breed;
  final String descriptionLabel;
  final String descriptionMissing;
  final String originLabel;
  final String intelligenceLabel;
  final String adaptabilityLabel;
  final String lifeSpanLabel;
  final String yearsLabel;
  final String notAvailableLabel;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(BrandSpacing.md),
    children: [
      Text(descriptionLabel, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: BrandSpacing.sm),
      Text(
        _present(breed.description, descriptionMissing),
        style: const TextStyle(color: BrandColors.ink, fontSize: 16),
      ),
      const SizedBox(height: BrandSpacing.lg),
      BreedFact(
        label: originLabel,
        value: _present(breed.origin, notAvailableLabel),
      ),
      const SizedBox(height: BrandSpacing.md),
      BreedFact(
        label: intelligenceLabel,
        value: breed.intelligence?.toString() ?? notAvailableLabel,
      ),
      const SizedBox(height: BrandSpacing.md),
      BreedFact(
        label: adaptabilityLabel,
        value: breed.adaptability?.toString() ?? notAvailableLabel,
      ),
      const SizedBox(height: BrandSpacing.md),
      BreedFact(
        label: lifeSpanLabel,
        value: breed.lifeSpan == null || breed.lifeSpan!.trim().isEmpty
            ? notAvailableLabel
            : '${breed.lifeSpan} $yearsLabel',
      ),
    ],
  );

  String _present(String? value, String fallback) =>
      value == null || value.trim().isEmpty ? fallback : value;
}
