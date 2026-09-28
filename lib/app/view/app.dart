import 'package:cat_breeds/app/router/app_router.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:cat_breeds/core/design_system/design_system.dart';
import 'package:cat_breeds/features/breeds/domain/domain.dart';
import 'package:cat_breeds/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const new({required this.config, required this.breedsRepository, super.key});

  final AppConfig config;
  final BreedsRepository breedsRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(repository: widget.breedsRepository);
  }

  @override
  void didUpdateWidget(covariant App oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.breedsRepository != oldWidget.breedsRepository) {
      _router.dispose();
      _router = createAppRouter(repository: widget.breedsRepository);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.config.applicationName,
      debugShowCheckedModeBanner: !widget.config.flavor.isProduction,
      theme: BrandTheme.light,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('es')],
      routerConfig: _router,
    );
  }
}
