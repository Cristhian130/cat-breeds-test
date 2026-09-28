import 'package:cat_breeds/app/di/breeds_dependencies.dart';
import 'package:cat_breeds/core/config/app_config.dart';
import 'package:cat_breeds/features/breeds/domain/domain.dart';
import 'package:get_it/get_it.dart';

/// La raíz de composición única para los servicios de aplicación.
///
/// Llama una vez por cada contenedor GetIt.
/// Las pruebas pueden pasar una instancia aislada.
void configureAppDependencies(GetIt services, AppConfig config) {
  services.registerSingleton<AppConfig>(config);
  registerBreedsData(services, config);
  services.registerFactory<SearchBreeds>(
    () => SearchBreeds(services<BreedsRepository>()),
  );
}
