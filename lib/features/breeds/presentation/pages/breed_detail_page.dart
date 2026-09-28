import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breed_detail_state.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/catalog_feedback.dart';
import 'package:cat_breeds/features/breeds/presentation/organisms/breed_detail_information.dart';
import 'package:cat_breeds/features/breeds/presentation/templates/breed_detail_template.dart';
import 'package:cat_breeds/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Límite de ruta: posee el BLoC de detalle y mapea su estado
/// a widgets visuales.
class BreedDetailPage extends StatelessWidget {
  const new({required this.repository, required this.breedId, super.key});

  final BreedsRepository repository;
  final String breedId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        BreedDetailBloc(repository, breedId)..add(const BreedDetailRequested()),
    child: const _BreedDetailView(),
  );
}

class _BreedDetailView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<BreedDetailBloc, BreedDetailState>(
      builder: (context, state) {
        final breed = state.breed;
        return BreedDetailTemplate(
          title: breed?.name ?? l10n.breedDetailTitle,
          backLabel: l10n.backToCatalog,
          onBack: () => Navigator.of(context).pop(),
          imageUrl: breed?.imageUrl,
          showPhoto: breed != null,
          content: switch (state.status) {
            BreedDetailStatus.initial || BreedDetailStatus.loading =>
              CatalogFeedback(message: l10n.loadingBreed, isLoading: true),
            BreedDetailStatus.failure => CatalogFeedback(
              message: _failureMessage(state.failure, l10n),
              retryLabel: l10n.retry,
              onRetry: () => context.read<BreedDetailBloc>().add(
                const BreedDetailRetryRequested(),
              ),
            ),
            BreedDetailStatus.success => BreedDetailInformation(
              breed: breed!,
              descriptionLabel: l10n.descriptionLabel,
              descriptionMissing: l10n.descriptionMissing,
              originLabel: l10n.originLabel,
              intelligenceLabel: l10n.intelligenceLabel,
              adaptabilityLabel: l10n.adaptabilityLabel,
              lifeSpanLabel: l10n.lifeSpanLabel,
              yearsLabel: l10n.yearsLabel,
              notAvailableLabel: l10n.notAvailable,
            ),
          },
        );
      },
    );
  }

  String _failureMessage(BreedsFailure? failure, AppLocalizations l10n) =>
      switch (failure) {
        BreedNotFoundFailure() => l10n.breedNotFound,
        ConnectionFailure() => l10n.connectionError,
        AccessDeniedFailure() => l10n.accessDenied,
        RateLimitFailure() => l10n.rateLimit,
        _ => l10n.genericError,
      };
}
