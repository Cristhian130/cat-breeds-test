import 'package:cat_breeds/app/router/splash_page.dart';
import 'package:cat_breeds/features/breeds/domain/domain.dart';
import 'package:cat_breeds/features/breeds/presentation/presentation.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({required BreedsRepository repository}) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/',
        name: 'catalog',
        builder: (context, state) => BreedsCatalogPage(repository: repository),
        routes: [
          GoRoute(
            path: 'breeds/:id',
            name: 'breed-detail',
            builder: (context, state) => BreedDetailPage(
              repository: repository,
              breedId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}
