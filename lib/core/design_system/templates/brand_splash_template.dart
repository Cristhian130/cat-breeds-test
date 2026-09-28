import 'package:cat_breeds/core/design_system/templates/adaptive_page_scaffold.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_colors.dart';
import 'package:flutter/material.dart';

/// Solo branding local, la pantalla de presentación
/// nunca espera una respuesta de la red.
class BrandSplashTemplate extends StatelessWidget {
  const new({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => AdaptivePageScaffold(
    body: ColoredBox(
      color: BrandColors.canvas,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/branding/splash_screen.jpg',
              excludeFromSemantics: true,
              fit: BoxFit.cover,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: BrandColors.splashText,
                        fontSize: 46,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
