import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cat_breeds/app/di/app_dependencies.dart';
import 'package:cat_breeds/core/config/config.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class AppBlocObserver extends BlocObserver {
  const new({required this.enableVerboseLogging});

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
  required FutureOr<Widget> Function(GetIt services) builder,
  GetIt? services,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = AppBlocObserver(
    enableVerboseLogging: config.enableVerboseLogging,
  );

  final container = services ?? GetIt.instance;
  configureAppDependencies(container, config);

  runApp(await builder(container));
}
