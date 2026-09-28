import 'package:cat_breeds/core/config/flavor.dart';

/// Configuración pública e inmutable de una ejecución de la aplicación.
///
/// Los valores de [String.fromEnvironment] se definen al compilar con
/// `--dart-define-from-file`. La clave no se guarda en Git, pero una app móvil
/// o web compilada siempre puede inspeccionarse.
class AppConfig {
  const new({
    required this.flavor,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.enableVerboseLogging,
    required this.enableDeveloperTools,
  });

  const new development()
    : flavor = Flavor.development,
      apiBaseUrl = _developmentApiBaseUrl,
      apiKey = _apiKey,
      enableVerboseLogging = true,
      enableDeveloperTools = true;

  const new staging()
    : flavor = Flavor.staging,
      apiBaseUrl = _stagingApiBaseUrl,
      apiKey = _apiKey,
      enableVerboseLogging = true,
      enableDeveloperTools = false;

  const new production()
    : flavor = Flavor.production,
      apiBaseUrl = _productionApiBaseUrl,
      apiKey = _apiKey,
      enableVerboseLogging = false,
      enableDeveloperTools = false;

  /// El entorno al que pertenece esta instalación.
  final Flavor flavor;

  /// URL pública del API. Debe ser HTTPS y no contener credenciales.
  final String apiBaseUrl;

  /// Valor para el encabezado `x-api-key` cuando se conecte el cliente HTTP.
  final String apiKey;

  /// Permite logs de transiciones de BLoC y diagnósticos de desarrollo.
  final bool enableVerboseLogging;

  /// Permite herramientas internas visibles solo en development.
  final bool enableDeveloperTools;

  String get applicationName => flavor.displayName;

  static const _developmentApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.thecatapi.com/v1',
  );

  static const _stagingApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.thecatapi.com/v1',
  );

  static const _productionApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.thecatapi.com/v1',
  );

  static const _apiKey = String.fromEnvironment('CAT_API_KEY');
}
