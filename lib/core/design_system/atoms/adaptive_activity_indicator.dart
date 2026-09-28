import 'package:cat_breeds/core/design_system/platform/platform_style.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

/// Indicador de carga nativo para la plataforma activa.
class AdaptiveActivityIndicator extends StatelessWidget {
  const new({this.strokeWidth = 4, super.key});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) => PlatformStyle.usesCupertino(context)
      ? const cupertino.CupertinoActivityIndicator()
      : CircularProgressIndicator(strokeWidth: strokeWidth);
}
