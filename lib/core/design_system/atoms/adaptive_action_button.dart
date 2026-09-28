import 'package:cat_breeds/core/design_system/platform/platform_style.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

enum AdaptiveActionButtonStyle { filled, outlined, text }

/// Control de acción nativo que conserva los tokens visuales del producto.
class AdaptiveActionButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.style = AdaptiveActionButtonStyle.filled,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AdaptiveActionButtonStyle style;

  @override
  Widget build(BuildContext context) {
    if (!PlatformStyle.usesCupertino(context)) {
      return switch (style) {
        AdaptiveActionButtonStyle.filled => FilledButton(
          onPressed: onPressed,
          child: Text(label),
        ),
        AdaptiveActionButtonStyle.outlined => OutlinedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
        AdaptiveActionButtonStyle.text => TextButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      };
    }

    return switch (style) {
      AdaptiveActionButtonStyle.filled => cupertino.CupertinoButton.filled(
        color: BrandColors.coral,
        onPressed: onPressed,
        child: Text(label),
      ),
      AdaptiveActionButtonStyle.outlined => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: BrandColors.coral),
          borderRadius: BorderRadius.circular(8),
        ),
        child: cupertino.CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(color: BrandColors.coral)),
        ),
      ),
      AdaptiveActionButtonStyle.text => cupertino.CupertinoButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: BrandColors.coral)),
      ),
    };
  }
}
