import 'package:bloc/bloc.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_state.dart';

/// Carga una raza por el ID de la ruta, los reintentos usan el mismo ID.
final class BreedDetailBloc extends Bloc<BreedDetailEvent, BreedDetailState> {
  new(this._repository, this._breedId)
    : super(const BreedDetailState.initial()) {
    on<BreedDetailRequested>(_load);
    on<BreedDetailRetryRequested>(_load);
  }

  final BreedsRepository _repository;
  final String _breedId;

  Future<void> _load(
    BreedDetailEvent event,
    Emitter<BreedDetailState> emit,
  ) async {
    if (state.status == BreedDetailStatus.loading) return;
    emit(const BreedDetailState.loading());
    final result = await _repository.getBreedById(_breedId);
    if (emit.isDone) return;
    switch (result) {
      case Success<Breed, BreedsFailure>(:final value):
        emit(BreedDetailState.success(value));
      case Failure<Breed, BreedsFailure>(:final error):
        emit(BreedDetailState.failed(error));
    }
  }
}
