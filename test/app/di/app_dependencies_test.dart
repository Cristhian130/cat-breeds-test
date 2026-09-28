import 'package:cat_breeds/app/di/app_dependencies.dart';
import 'package:cat_breeds/core/config/app_config.dart';
import 'package:cat_breeds/core/config/flavor.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  test('keeps flavors isolated in separate containers', () async {
    final development = GetIt.asNewInstance();
    final production = GetIt.asNewInstance();
    addTearDown(development.reset);
    addTearDown(production.reset);

    const developmentConfig = AppConfig(
      flavor: Flavor.development,
      apiBaseUrl: 'https://dev.example.test/v1',
      apiKey: 'development-test-key',
      enableVerboseLogging: true,
      enableDeveloperTools: true,
    );
    const productionConfig = AppConfig(
      flavor: Flavor.production,
      apiBaseUrl: 'https://production.example.test/v1',
      apiKey: 'production-test-key',
      enableVerboseLogging: false,
      enableDeveloperTools: false,
    );

    configureAppDependencies(development, developmentConfig);
    configureAppDependencies(production, productionConfig);

    expect(development<AppConfig>(), same(developmentConfig));
    expect(production<AppConfig>(), same(productionConfig));
    expect(development<Dio>().options.baseUrl, 'https://dev.example.test/v1/');
    expect(
      production<Dio>().options.baseUrl,
      'https://production.example.test/v1/',
    );
    expect(
      development<Dio>().options.headers['x-api-key'],
      'development-test-key',
    );
    expect(
      production<Dio>().options.headers['x-api-key'],
      'production-test-key',
    );
    expect(
      development<BreedsRepository>(),
      isNot(same(production<BreedsRepository>())),
    );
  });

  test('SearchBreeds receives an overridable repository', () async {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    configureAppDependencies(services, const AppConfig.development());
    await services.unregister<BreedsRepository>();
    final fake = _FakeBreedsRepository();
    services.registerSingleton<BreedsRepository>(fake);

    final first = services<SearchBreeds>();
    final second = services<SearchBreeds>();
    final result = await first(query: ' siamese ');

    expect(first, isNot(same(second)));
    expect(fake.receivedName, 'siamese');
    expect(result, isA<Success<BreedsPage, BreedsFailure>>());
  });
}

final class _FakeBreedsRepository implements BreedsRepository {
  String? receivedName;

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) async =>
      Success(BreedsPage(items: const [], page: page, hasNextPage: false));

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) async {
    receivedName = name;
    return Success(BreedsPage(items: const [], page: page, hasNextPage: false));
  }

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) {
    throw UnimplementedError('Not needed by the composition test');
  }
}
