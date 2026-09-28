import 'dart:math' as math;

import 'package:cat_breeds/core/design_system/tokens/brand_breakpoints.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_card.dart';
import 'package:flutter/material.dart';

/// Construye de forma diferida una lista en teléfonos y una grilla de dos
/// columnas en pantallas amplias.
class BreedsCatalogCollection extends StatelessWidget {
  const new({
    required this.breeds,
    required this.originLabel,
    required this.intelligenceLabel,
    required this.notAvailableLabel,
    required this.moreLabel,
    required this.onBreedSelected,
    super.key,
  });

  final List<Breed> breeds;
  final String originLabel;
  final String intelligenceLabel;
  final String notAvailableLabel;
  final String moreLabel;
  final ValueChanged<String> onBreedSelected;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.crossAxisExtent;
      if (width >= BrandBreakpoints.catalogTwoColumns &&
          MediaQuery.textScalerOf(context).scale(1) <= 1.2) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final inset = math.max(
          BrandSpacing.md,
          (width - BrandBreakpoints.catalogGridMaxWidth) / 2,
        );
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          sliver: SliverGrid.builder(
            itemCount: breeds.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: BrandSpacing.md,
              crossAxisSpacing: BrandSpacing.md,
              mainAxisExtent: 440 + (textScale - 1) * 300,
            ),
            itemBuilder: (context, index) => _card(index),
          ),
        );
      }
      final inset = math.max(
        BrandSpacing.md,
        (width - BrandBreakpoints.contentMaxWidth) / 2,
      );
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        sliver: SliverList.builder(
          itemCount: breeds.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: BrandSpacing.md),
            child: _card(index),
          ),
        ),
      );
    },
  );

  Widget _card(int index) => BreedCard(
    key: ValueKey(breeds[index].id),
    breed: breeds[index],
    originLabel: originLabel,
    intelligenceLabel: intelligenceLabel,
    notAvailableLabel: notAvailableLabel,
    moreLabel: moreLabel,
    onMore: () => onBreedSelected(breeds[index].id),
  );
}
