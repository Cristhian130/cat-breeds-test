import 'dart:math' as math;

import 'package:cat_breeds/core/design_system/atoms/brand_photo.dart';
import 'package:cat_breeds/core/design_system/templates/adaptive_page_scaffold.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_breakpoints.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:flutter/material.dart';

/// Mantiene fija la imagen mientras los datos de la raza se desplazan debajo.
class BreedDetailTemplate extends StatelessWidget {
  const new({
    required this.title,
    required this.backLabel,
    required this.onBack,
    required this.content,
    this.imageUrl,
    this.showPhoto = false,
    super.key,
  });

  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget content;
  final String? imageUrl;
  final bool showPhoto;

  @override
  Widget build(BuildContext context) => AdaptivePageScaffold(
    title: title,
    backLabel: backLabel,
    onBack: onBack,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: BrandBreakpoints.contentMaxWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                if (showPhoto)
                  Padding(
                    padding: const EdgeInsets.all(BrandSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      height: math.min(
                        constraints.maxHeight *
                            (constraints.maxHeight <
                                        BrandBreakpoints.compactDetailHeight ||
                                    MediaQuery.textScalerOf(context).scale(1) >
                                        1.2
                                ? 0.28
                                : 0.42),
                        320,
                      ),
                      child: BrandPhoto(
                        imageUrl: imageUrl,
                        semanticLabel: title,
                      ),
                    ),
                  ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
