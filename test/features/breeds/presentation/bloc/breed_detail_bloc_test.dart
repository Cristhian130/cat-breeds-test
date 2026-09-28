import 'dart:async';

import 'package:cat_breeds/features/breeds/domain/entities/breed.dart';
import 'package:cat_breeds/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_breeds/features/breeds/domain/entities/result.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores duplicate requests while detail is loading', () async {
    final pending = Completer<Result<Breed, BreedsFailure>>();
    final repository = _DetailRepository((_) => pending.future);
    final bloc = BreedDetailBloc(repository, 'abys');
    addTearDown(bloc.close);

    bloc
      ..add(const BreedDetailRequested())
      ..add(const BreedDetailRetryRequested())
      ..add(const BreedDetailRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repository.requestedIds, ['abys']);
    final ready = bloc.stream.firstWhere(
      (state) => state.status == BreedDetailStatus.success,
    );
    pending.complete(Success(Breed(id: 'abys', name: 'Abyssinian')));
    expect((await ready).breed?.id, 'abys');
  });

  test('loads the route ID and emits loading then success', () async {
    final result = Completer<Result<Breed, BreedsFailure>>();
    final repository = _DetailRepository((_) => result.future);
    final bloc = BreedDetailBloc(repository, 'abys');
    addTearDown(bloc.close);

    bloc.add(const BreedDetailRequested());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, BreedDetailStatus.loading);
    expect(repository.requestedIds, ['abys']);

    result.complete(Success(Breed(id: 'abys', name: 'Abyssinian')));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, BreedDetailStatus.success);
    expect(bloc.state.breed?.name, 'Abyssinian');
  });

  test('retry reloads the same ID after an error', () async {
    var calls = 0;
    final repository = _DetailRepository((id) async {
      calls++;
      if (calls == 1) {
        return const Failure(BreedNotFoundFailure());
      }
      return Success(Breed(id: id, name: 'Abyssinian'));
    });
    final bloc = BreedDetailBloc(repository, 'abys');
    addTearDown(bloc.close);

    bloc.add(const BreedDetailRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.failure, isA<BreedNotFoundFailure>());

    bloc.add(const BreedDetailRetryRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.status, BreedDetailStatus.success);
    expect(repository.requestedIds, ['abys', 'abys']);
  });
}

final class _DetailRepository implements BreedsRepository {
  new(this.respond);

  final Future<Result<Breed, BreedsFailure>> Function(String) respond;
  final List<String> requestedIds = [];

  @override
  Future<Result<Breed, BreedsFailure>> getBreedById(String id) {
    requestedIds.add(id);
    return respond(id);
  }

  @override
  Future<Result<BreedsPage, BreedsFailure>> getBreeds({
    required int page,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<Result<BreedsPage, BreedsFailure>> searchBreeds({
    required String name,
    required int page,
    required int limit,
  }) => throw UnimplementedError();
}
