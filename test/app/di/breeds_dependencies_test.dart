import 'dart:convert';

import 'package:cat_breeds/app/di/breeds_dependencies.dart';
import 'package:cat_breeds/core/config/app_config.dart';
import 'package:cat_breeds/core/config/flavor.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  test('registers the API client and the domain port', () async {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    const config = AppConfig(
      flavor: Flavor.development,
      apiBaseUrl: 'https://api.thecatapi.com/v1',
      apiKey: 'test-key',
      enableVerboseLogging: false,
      enableDeveloperTools: false,
    );

    registerBreedsData(services, config);

    final dio = services<Dio>();
    expect(dio.options.baseUrl, 'https://api.thecatapi.com/v1/');
    expect(dio.options.headers['x-api-key'], 'test-key');
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.headers['x-api-key'], 'test-key');
          expect(options.uri.queryParameters.containsKey('api_key'), isFalse);
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: [
                {'id': 'siam', 'name': 'Siamese'},
              ],
            ),
          );
        },
      ),
    );

    final result = await services<BreedsRepository>().getBreeds(
      page: 0,
      limit: 20,
    );
    expect(result, isA<Success<BreedsPage, BreedsFailure>>());
    final page = (result as Success<BreedsPage, BreedsFailure>).value;
    expect(page.items.single.name, 'Siamese');
  });

  test('diagnostic HTTP logs never print the API key', () async {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    final messages = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = previousDebugPrint);
    const config = AppConfig(
      flavor: Flavor.development,
      apiBaseUrl: 'https://api.thecatapi.com/v1',
      apiKey: 'sensitive-test-key',
      enableVerboseLogging: true,
      enableDeveloperTools: false,
    );
    registerBreedsData(services, config);
    final dio = services<Dio>();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<Object?>(requestOptions: options, statusCode: 200),
          true,
        ),
      ),
    );

    await dio.get<Object?>('breeds');

    expect(messages.join(' '), contains('keyPresent=true'));
    expect(messages.join(' '), contains('status=200 elapsedMs='));
    expect(messages.join(' '), isNot(contains('sensitive-test-key')));
  });

  test(
    'large JSON uses the configured background decoder without losing data',
    () async {
      final services = GetIt.asNewInstance();
      addTearDown(services.reset);
      registerBreedsData(services, const AppConfig.production());
      final transformer = services<Dio>().transformer as FusedTransformer;
      expect(transformer.contentLengthIsolateThreshold, 50 * 1024);
      final records = List.generate(
        1000,
        (index) => {
          'id': '$index',
          'name': 'Abyssinian',
          'description': 'x' * 100,
        },
      );
      final json = jsonEncode(records);
      expect(json.length, greaterThan(50 * 1024));

      final decoded = await transformer.transformResponse(
        RequestOptions(path: 'breeds'),
        ResponseBody.fromString(
          json,
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );

      expect(decoded, records);
    },
  );

  test('omits x-api-key when no key was configured', () async {
    final services = GetIt.asNewInstance();
    addTearDown(services.reset);
    const config = AppConfig(
      flavor: Flavor.development,
      apiBaseUrl: 'https://api.thecatapi.com/v1/',
      apiKey: '',
      enableVerboseLogging: false,
      enableDeveloperTools: false,
    );
    registerBreedsData(services, config);

    final dio = services<Dio>();
    expect(dio.options.baseUrl, 'https://api.thecatapi.com/v1/');
    expect(dio.options.headers, isNot(contains('x-api-key')));
  });
}
