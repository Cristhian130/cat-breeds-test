import 'package:cat_breeds/core/design_system/tokens/brand_breakpoints.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/breed_search_field.dart';
import 'package:cat_breeds/features/breeds/presentation/templates/breed_intro_template.dart';
import 'package:flutter/material.dart';

/// Ordena secciones visuales sin conocer BLoC, repositorios ni modelos de API.
class BreedsCatalogTemplate extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.heroImageUrl,
    required this.imageLabel,
    required this.searchHint,
    required this.onQueryChanged,
    required this.contentSliver,
    this.footerSliver,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? heroImageUrl;
  final String imageLabel;
  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final Widget contentSliver;
  final Widget? footerSliver;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BreedIntroTemplate(
            title: title,
            subtitle: subtitle,
            imageUrl: heroImageUrl,
            imageLabel: imageLabel,
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: BrandBreakpoints.contentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BrandSpacing.md,
                  BrandSpacing.xl,
                  BrandSpacing.md,
                  BrandSpacing.md,
                ),
                child: BreedSearchField(
                  hint: searchHint,
                  onChanged: onQueryChanged,
                ),
              ),
            ),
          ),
        ),
        contentSliver,
        ?footerSliver,
      ],
    ),
  );
}
