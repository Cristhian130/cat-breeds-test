import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver({required this.enableVerboseLogging});

  final bool enableVerboseLogging;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (enableVerboseLogging) {
      log('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap({
  required AppConfig config,
  required FutureOr<Widget> Function() builder,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = AppBlocObserver(
    enableVerboseLogging: config.enableVerboseLogging,
  );

  // Registra aquí adaptadores transversales que dependan del entorno, por
  // ejemplo Crashlytics, analítica o un cliente HTTP. No registres secretos:
  // una aplicación compilada no es un lugar seguro para almacenarlos.

  runApp(await builder());
}
