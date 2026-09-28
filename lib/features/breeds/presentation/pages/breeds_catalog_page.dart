import 'package:cat_breeds/core/design_system/atoms/adaptive_action_button.dart';
import 'package:cat_breeds/core/design_system/atoms/adaptive_activity_indicator.dart';
import 'package:cat_breeds/core/design_system/templates/adaptive_page_scaffold.dart';
import 'package:cat_breeds/core/design_system/tokens/brand_spacing.dart';
import 'package:cat_breeds/features/breeds/domain/failures/breeds_failure.dart';
import 'package:cat_breeds/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_breeds/features/breeds/domain/use_cases/search_breeds.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_bloc.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_event.dart';
import 'package:cat_breeds/features/breeds/presentation/bloc/breeds_catalog_state.dart';
import 'package:cat_breeds/features/breeds/presentation/molecules/catalog_feedback.dart';
import 'package:cat_breeds/features/breeds/presentation/organisms/breeds_catalog_collection.dart';
import 'package:cat_breeds/features/breeds/presentation/templates/breeds_catalog_template.dart';
import 'package:cat_breeds/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// La página es el límite de composición entre BLoC y Atomic Design.
class BreedsCatalogPage extends StatelessWidget {
  const new({required this.repository, super.key});

  final BreedsRepository repository;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        BreedsCatalogBloc(SearchBreeds(repository))
          ..add(const CatalogStarted()),
    child: const _CatalogView(),
  );
}

class _CatalogView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<BreedsCatalogBloc>();
    return AdaptivePageScaffold(
      body: BlocBuilder<BreedsCatalogBloc, BreedsCatalogState>(
        builder: (context, state) => BreedsCatalogTemplate(
          title: l10n.exploreTitle,
          subtitle: l10n.exploreSubtitle,
          heroImageUrl: state.heroImageUrl,
          imageLabel: l10n.heroCatImageLabel,
          searchHint: l10n.searchBreedsHint,
          onQueryChanged: (query) => bloc.add(CatalogQueryChanged(query)),
          contentSliver: _contentSliver(context, state, l10n, bloc),
          footerSliver: _footerSliver(state, l10n, bloc),
        ),
      ),
    );
  }

  Widget _contentSliver(
    BuildContext context,
    BreedsCatalogState state,
    AppLocalizations l10n,
    BreedsCatalogBloc bloc,
  ) => switch (state.status) {
    CatalogStatus.initial || CatalogStatus.loading => SliverToBoxAdapter(
      child: CatalogFeedback(message: l10n.loadingBreeds, isLoading: true),
    ),
    CatalogStatus.empty => SliverToBoxAdapter(
      child: CatalogFeedback(
        message: state.query.trim().isEmpty
            ? l10n.noBreeds
            : l10n.noSearchResults,
      ),
    ),
    CatalogStatus.failure => SliverToBoxAdapter(
      child: CatalogFeedback(
        message: _failureMessage(state.failure, l10n),
        retryLabel: l10n.retry,
        onRetry: () => bloc.add(const CatalogRetryRequested()),
      ),
    ),
    CatalogStatus.success => BreedsCatalogCollection(
      breeds: state.breeds,
      originLabel: l10n.originLabel,
      intelligenceLabel: l10n.intelligenceLabel,
      notAvailableLabel: l10n.notAvailable,
      moreLabel: l10n.moreDetails,
      onBreedSelected: (id) =>
          context.pushNamed('breed-detail', pathParameters: {'id': id}),
    ),
  };

  Widget? _footerSliver(
    BreedsCatalogState state,
    AppLocalizations l10n,
    BreedsCatalogBloc bloc,
  ) {
    if (state.status != CatalogStatus.success ||
        (!state.hasMore &&
            !state.isLoadingMore &&
            state.loadMoreFailure == null)) {
      return null;
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.md),
        child: Center(
          child: state.loadMoreFailure != null
              ? CatalogFeedback(
                  message: _failureMessage(state.loadMoreFailure, l10n),
                  retryLabel: l10n.retry,
                  onRetry: () => bloc.add(const CatalogRetryRequested()),
                )
              : state.isLoadingMore
              ? const AdaptiveActivityIndicator()
              : AdaptiveActionButton(
                  label: l10n.loadMore,
                  onPressed: () => bloc.add(const CatalogLoadMoreRequested()),
                  style: AdaptiveActionButtonStyle.outlined,
                ),
        ),
      ),
    );
  }

  String _failureMessage(BreedsFailure? failure, AppLocalizations l10n) =>
      switch (failure) {
        ConnectionFailure() => l10n.connectionError,
        AccessDeniedFailure() => l10n.accessDenied,
        RateLimitFailure() => l10n.rateLimit,
        InvalidSearchTermFailure() => l10n.searchTooLong,
        _ => l10n.genericError,
      };
}
