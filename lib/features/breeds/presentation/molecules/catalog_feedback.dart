import 'package:cat_breeds/core/design_system/atoms/adaptive_action_button.dart';
import 'package:cat_breeds/core/design_system/atoms/adaptive_activity_indicator.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:flutter/material.dart';

/// Los estados vacíos y de error comparten un lenguaje visual accesible.
class CatalogFeedback extends StatelessWidget {
  const new({
    required this.message,
    this.isLoading = false,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String message;
  final bool isLoading;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(BrandSpacing.xl),
      child: Column(
        children: [
          if (isLoading) ...[
            const AdaptiveActivityIndicator(),
            const SizedBox(height: BrandSpacing.md),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BrandColors.mutedInk, fontSize: 16),
          ),
          if (onRetry != null && retryLabel != null) ...[
            const SizedBox(height: BrandSpacing.md),
            AdaptiveActionButton(label: retryLabel!, onPressed: onRetry),
          ],
        ],
      ),
    ),
  );
}
