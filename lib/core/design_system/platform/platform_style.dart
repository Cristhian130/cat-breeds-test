import 'package:flutter/material.dart';

/// Mantiene la decisión de plataforma fuera de las páginas y componentes
/// del feature.
abstract final class PlatformStyle {
  static bool usesCupertino(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;
}
