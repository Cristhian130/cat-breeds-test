import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/material.dart';

/// Poppins está incluida en los assets, así el diseño no requiere fuentes
/// en tiempo de ejecución.
abstract final class BrandTypography {
  static const family = 'Poppins';

  static const heroTitle = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: BrandColors.ink,
  );

  static const heroSubtitle = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: BrandColors.mutedInk,
  );

  static const sectionTitle = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: BrandColors.coral,
  );

  static const sectionSubtitle = TextStyle(
    fontFamily: family,
    fontSize: 21,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: BrandColors.coral,
  );
}
