// Los constructores con nombre no pueden usar la sintaxis abreviada `new`
// de Dart.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';

enum BreedDetailStatus { initial, loading, success, failure }

final class BreedDetailState {
  const BreedDetailState._(this.status, {this.breed, this.failure});

  const BreedDetailState.initial() : this._(BreedDetailStatus.initial);
  const BreedDetailState.loading() : this._(BreedDetailStatus.loading);
  const BreedDetailState.success(Breed breed)
    : this._(BreedDetailStatus.success, breed: breed);
  const BreedDetailState.failed(BreedsFailure failure)
    : this._(BreedDetailStatus.failure, failure: failure);

  final BreedDetailStatus status;
  final Breed? breed;
  final BreedsFailure? failure;
}
