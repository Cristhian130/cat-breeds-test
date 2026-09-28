import 'dart:developer';

import 'package:cat_breeds/features/breeds/data/models/breed_dto.dart';
import 'package:cat_breeds/features/breeds/data/models/breeds_page_dto.dart';
import 'package:cat_breeds/features/breeds/data/sources/breeds_remote_data_source.dart';
import 'package:dio/dio.dart';

/// Implementación de The Cat API. La instancia de Dio la entrega
/// la composición.
final class DioBreedsRemoteDataSource implements BreedsRemoteDataSource {
  const new(this._dio);

  final Dio _dio;

  @override
  Future<BreedsPageDto> getBreeds({required int page, required int limit}) =>
      _getPage('breeds', page: page, limit: limit);

  @override
  Future<BreedsPageDto> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) => _getPage('breeds/search', page: page, limit: limit, query: name);

  @override
  Future<BreedDto> getBreedById(String id) async {
    final response = await _dio.get<Object?>(
      'breeds/${Uri.encodeComponent(id)}',
      queryParameters: const {'lang': 'en'},
    );
    return BreedDto.fromJson(response.data);
  }

  Future<BreedsPageDto> _getPage(
    String path, {
    required int page,
    required int limit,
    String? query,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: {
        'limit': limit,
        'page': page,
        'lang': 'en',
        if (query == null) 'order': 'ASC' else 'q': query,
      },
    );

    final responsePage = _nonNegativeHeader(
      response.headers,
      'pagination-page',
    );
    final responseLimit = _positiveHeader(response.headers, 'pagination-limit');
    final totalCount = _nonNegativeHeader(response.headers, 'pagination-count');

    final result = BreedsPageDto.fromJson(
      response.data,
      page: responsePage ?? page,
      limit: responseLimit ?? limit,
      totalCount: totalCount,
    );
    if (result.discardedCount > 0) {
      log(
        'Skipped ${result.discardedCount} malformed breed records',
        name: 'DioBreedsRemoteDataSource',
      );
    }
    return result;
  }

  static int? _nonNegativeHeader(Headers headers, String name) {
    final value = int.tryParse(headers.value(name) ?? '');
    return value != null && value >= 0 ? value : null;
  }

  static int? _positiveHeader(Headers headers, String name) {
    final value = int.tryParse(headers.value(name) ?? '');
    return value != null && value > 0 ? value : null;
  }
}
