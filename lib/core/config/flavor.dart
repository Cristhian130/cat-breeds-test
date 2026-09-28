/// Entornos de ejecución soportados por la aplicación.
///
/// Un flavor identifica la infraestructura que usa la app. No debe utilizarse
/// para activar experimentos de producto, para eso se usan feature flags.
enum Flavor {
  development,
  staging,
  production;

  String get displayName => switch (this) {
    Flavor.development => 'Development',
    Flavor.staging => 'Staging',
    Flavor.production => 'Cat Breeds',
  };

  bool get isProduction => this == Flavor.production;
}
