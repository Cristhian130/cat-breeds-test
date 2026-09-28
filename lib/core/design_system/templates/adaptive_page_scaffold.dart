import 'package:cat_breeds/core/design_system/platform/platform_style.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

/// Contenedor de pantalla que proporciona navegación Material
/// o Cupertino según la plataforma.
class AdaptivePageScaffold extends StatelessWidget {
  const new({
    required this.body,
    this.title,
    this.backLabel,
    this.onBack,
    super.key,
  });

  final Widget body;
  final String? title;
  final String? backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.usesCupertino(context)) {
      return cupertino.CupertinoPageScaffold(
        backgroundColor: BrandColors.canvas,
        navigationBar: title == null
            ? null
            : cupertino.CupertinoNavigationBar(
                automaticallyImplyLeading: false,
                leading: onBack == null
                    ? null
                    : cupertino.CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onBack,
                        child: const Icon(cupertino.CupertinoIcons.back),
                      ),
                middle: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        child: body,
      );
    }

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              leading: onBack == null
                  ? null
                  : IconButton(
                      tooltip: backLabel,
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
              title: Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
      body: body,
    );
  }
}
