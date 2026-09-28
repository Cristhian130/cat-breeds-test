import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_radii.dart';
import 'package:flutter/material.dart';

class AccentBar extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 48,
    decoration: BoxDecoration(
      color: BrandColors.coral,
      borderRadius: BorderRadius.circular(BrandRadii.accent),
    ),
  );
}
