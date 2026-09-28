import 'package:cat_breeds/core/design_system/platform/platform_style.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

/// Campo de búsqueda nativo para la plataforma activa
/// que utiliza elementos visuales compartidos.
class AdaptiveSearchField extends StatelessWidget {
  const new({required this.hint, required this.onChanged, super.key});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.usesCupertino(context)) {
      return cupertino.CupertinoTextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        placeholder: hint,
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(
            cupertino.CupertinoIcons.search,
            color: BrandColors.coral,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: BrandColors.canvas,
          border: Border.all(color: BrandColors.mutedInk),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: BrandColors.coral),
        filled: true,
        fillColor: BrandColors.canvas,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BrandColors.mutedInk),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BrandColors.coral, width: 2),
        ),
      ),
    );
  }
}
