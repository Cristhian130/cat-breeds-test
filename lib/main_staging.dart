import 'package:cat_breeds/app/app.dart';
import 'package:cat_breeds/bootstrap.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';

Future<void> main() async {
  const config = AppConfig.staging();
  await bootstrap(
    config: config,
    builder: (services) =>
        App(config: config, breedsRepository: services<BreedsRepository>()),
  );
}
