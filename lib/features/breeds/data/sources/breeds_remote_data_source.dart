import 'package:cat_breeds/features/breeds/data/models/breed_dto.dart';
import 'package:cat_breeds/features/breeds/data/models/breeds_page_dto.dart';

/// Contrato orientado a HTTP usado por el adaptador del repositorio.
abstract interface class BreedsRemoteDataSource {
  Future<BreedsPageDto> getBreeds({required int page, required int limit});

  Future<BreedsPageDto> searchBreeds({
    required String name,
    required int page,
    required int limit,
  });

  Future<BreedDto> getBreedById(String id);
}
