import 'package:cat_breeds/core/config/flavor.dart';

/// Configuración pública e inmutable de una ejecución de la aplicación.
///
/// Los valores de [String.fromEnvironment] se definen al compilar con
/// `--dart-define`. No incluyas secretos aquí: el binario de una app móvil o
/// web siempre puede inspeccionarse.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableVerboseLogging,
    required this.enableDeveloperTools,
  });

  const AppConfig.development()
    : flavor = Flavor.development,
      apiBaseUrl = _developmentApiBaseUrl,
      enableVerboseLogging = true,
      enableDeveloperTools = true;

  const AppConfig.staging()
    : flavor = Flavor.staging,
      apiBaseUrl = _stagingApiBaseUrl,
      enableVerboseLogging = true,
      enableDeveloperTools = false;

  const AppConfig.production()
    : flavor = Flavor.production,
      apiBaseUrl = _productionApiBaseUrl,
      enableVerboseLogging = false,
      enableDeveloperTools = false;

  /// El entorno al que pertenece esta instalación.
  final Flavor flavor;

  /// URL pública del API. Debe ser HTTPS y no contener credenciales.
  final String apiBaseUrl;

  /// Permite logs de transiciones de BLoC y diagnósticos de desarrollo.
  final bool enableVerboseLogging;

  /// Permite herramientas internas visibles solo en development.
  final bool enableDeveloperTools;

  String get applicationName => flavor.displayName;

  static const _developmentApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.catbreeds.invalid',
  );

  static const _stagingApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.staging.catbreeds.invalid',
  );

  static const _productionApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.catbreeds.invalid',
  );
}
