sealed class BreedsCatalogEvent {
  const new();
}

final class CatalogStarted extends BreedsCatalogEvent {
  const new();
}

final class CatalogQueryChanged extends BreedsCatalogEvent {
  const new(this.query);

  final String query;
}

final class CatalogLoadMoreRequested extends BreedsCatalogEvent {
  const new();
}

final class CatalogRetryRequested extends BreedsCatalogEvent {
  const new();
}

final class CatalogSearchDue extends BreedsCatalogEvent {
  const new(this.revision);

  final int revision;
}
