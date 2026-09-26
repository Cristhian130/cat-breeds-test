import 'package:cat_breeds/app/app.dart';
import 'package:cat_breeds/bootstrap.dart';
import 'package:cat_breeds/core/config/config.dart';

Future<void> main() async {
  const config = AppConfig.production();
  await bootstrap(
    config: config,
    builder: () => const App(config: config),
  );
}
