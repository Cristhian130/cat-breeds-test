import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_typography.dart';
import 'package:flutter/material.dart';

/// Tema claro compartido que coincide con la referencia proporcionada.
abstract final class BrandTheme {
  static ThemeData get light => ThemeData(
    fontFamily: BrandTypography.family,
    colorScheme: const ColorScheme.light(
      primary: BrandColors.coral,
      onSurface: BrandColors.ink,
    ),
    textTheme: const TextTheme(
      headlineLarge: BrandTypography.heroTitle,
      headlineMedium: BrandTypography.sectionTitle,
      bodyLarge: BrandTypography.sectionSubtitle,
      bodyMedium: BrandTypography.heroSubtitle,
    ),
  );
}
