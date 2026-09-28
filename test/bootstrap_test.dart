import 'package:bloc/bloc.dart';
import 'package:cat_breeds/bootstrap.dart';
import 'package:cat_breeds/core/config/app_config.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  testWidgets('bootstrap composes services before building the app', (
    tester,
  ) async {
    final services = GetIt.asNewInstance();
    final previousObserver = Bloc.observer;
    final previousErrorHandler = FlutterError.onError;
    addTearDown(() async {
      await services.reset();
      Bloc.observer = previousObserver;
      FlutterError.onError = previousErrorHandler;
    });

    await bootstrap(
      config: const AppConfig.development(),
      services: services,
      builder: (container) {
        expect(container, same(services));
        expect(container.isRegistered<SearchBreeds>(), isTrue);
        return const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('ready'),
        );
      },
    );
    await tester.pump();

    expect(find.text('ready'), findsOneWidget);
  });
}
