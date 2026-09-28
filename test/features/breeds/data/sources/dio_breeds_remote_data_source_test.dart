import 'package:cat_breeds/features/breeds/data/sources/dio_breeds_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;
  late DioBreedsRemoteDataSource source;
  late RequestOptions request;
  Object? responseData;
  var responseHeaders = <String, List<String>>{};

  setUp(() {
    responseData = [
      {'id': 'siam', 'name': 'Siamese'},
    ];
    responseHeaders = {};
    dio = Dio(BaseOptions(baseUrl: 'https://api.thecatapi.com/v1/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          request = options;
          handler.resolve(
            Response<Object?>(
              requestOptions: options,
              statusCode: 200,
              data: responseData,
              headers: Headers.fromMap(responseHeaders),
            ),
          );
        },
      ),
    );
    source = DioBreedsRemoteDataSource(dio);
  });

  tearDown(() => dio.close());

  test('list sends page, limit, English language and stable order', () async {
    responseHeaders = {
      'pagination-count': ['25'],
      'pagination-page': ['0'],
      'pagination-limit': ['20'],
    };

    final page = await source.getBreeds(page: 0, limit: 20);

    expect(request.path, 'breeds');
    expect(request.uri.path, '/v1/breeds');
    expect(request.queryParameters, {
      'limit': 20,
      'page': 0,
      'lang': 'en',
      'order': 'ASC',
    });
    expect(page.hasNextPage, isTrue);
  });

  test('search sends q and handles missing pagination headers', () async {
    final page = await source.searchBreeds(name: 'siamese', page: 0, limit: 20);

    expect(request.path, 'breeds/search');
    expect(request.queryParameters['q'], 'siamese');
    expect(request.queryParameters.containsKey('order'), isFalse);
    expect(page.items.single.name, 'Siamese');
    expect(page.hasNextPage, isFalse);
  });

  test('detail requests a breed by ID', () async {
    responseData = {'id': 'siam', 'name': 'Siamese'};

    final breed = await source.getBreedById('siam');

    expect(request.path, 'breeds/siam');
    expect(request.queryParameters, {'lang': 'en'});
    expect(breed.id, 'siam');
  });

  test('rejects a non-list response for listing', () async {
    responseData = {'error': 'invalid'};

    expect(source.getBreeds(page: 0, limit: 20), throwsFormatException);
  });
}
