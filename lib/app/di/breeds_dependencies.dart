import 'package:cat_breeds/core/config/app_config.dart';
import 'package:cat_breeds/features/breeds/data/data.dart';
import 'package:cat_breeds/features/breeds/domain/domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Compone el adaptador de datos sin exponer Dio a la capa de dominio.
void registerBreedsData(GetIt services, AppConfig config) {
  final baseUrl = config.apiBaseUrl.endsWith('/')
      ? config.apiBaseUrl
      : '${config.apiBaseUrl}/';

  services
    ..registerLazySingleton<Dio>(() {
      final dio =
          Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  if (config.apiKey.isNotEmpty) 'x-api-key': config.apiKey,
                },
              ),
            )
            // Las cargas útiles pequeñas evitan la sobrecarga
            //del worker nativo de Dio.
            ..transformer = FusedTransformer(
              contentLengthIsolateThreshold: 50 * 1024,
            );
      if (config.enableVerboseLogging) {
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              options.extra['requestTimer'] = Stopwatch()..start();
              final hasKey = options.headers.keys.any(
                (name) => name.toLowerCase() == 'x-api-key',
              );
              debugPrint(
                'BreedsHttp ${options.method} ${options.uri.path} '
                'keyPresent=$hasKey',
              );
              handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint(
                'BreedsHttp ${response.requestOptions.uri.path} '
                'status=${response.statusCode} '
                'elapsedMs=${_elapsedMs(response.requestOptions)}',
              );
              handler.next(response);
            },
            onError: (error, handler) {
              debugPrint(
                'BreedsHttp ${error.requestOptions.uri.path} '
                'status=${error.response?.statusCode} '
                'type=${error.type.name} '
                'elapsedMs=${_elapsedMs(error.requestOptions)}',
              );
              handler.next(error);
            },
          ),
        );
      }
      return dio;
    }, dispose: (dio) => dio.close())
    ..registerLazySingleton<BreedsRemoteDataSource>(
      () => DioBreedsRemoteDataSource(services<Dio>()),
    )
    ..registerLazySingleton<BreedsRepository>(
      () => BreedsRepositoryImpl(services<BreedsRemoteDataSource>()),
    );
}

int? _elapsedMs(RequestOptions options) {
  final timer = options.extra.remove('requestTimer') as Stopwatch?;
  timer?.stop();
  return timer?.elapsedMilliseconds;
}
