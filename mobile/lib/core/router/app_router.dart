import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/catches/catches_screen.dart';
import '../../features/collection/collection_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/recipes/recipes_screen.dart';
import '../../features/scan/discovery_screen.dart';
import '../../features/scan/scan_result_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/tutorials/tutorials_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register' || loc == '/';
      if (!auth.authenticated && !loggingIn) return '/login';
      if (auth.authenticated && (loc == '/login' || loc == '/register')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/map', builder: (_, __) => const MapScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/scan', builder: (_, __) => const ScanScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/feed', builder: (_, __) => const FeedScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),
      GoRoute(
        path: '/scan/result',
        builder: (_, state) => ScanResultScreen(payload: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/scan/discovery',
        builder: (_, state) => DiscoveryScreen(catchData: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/scan/already',
        builder: (_, state) => AlreadyCollectedScreen(catchData: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/collection', builder: (_, __) => const CollectionScreen()),
      GoRoute(path: '/catches', builder: (_, __) => const CatchesScreen()),
      GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen()),
      GoRoute(
        path: '/recipes/:id',
        builder: (_, state) => RecipeDetailScreen(recipe: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/tutorials', builder: (_, __) => const TutorialsScreen()),
      GoRoute(
        path: '/tutorials/:id',
        builder: (_, state) => TutorialDetailScreen(tutorial: state.extra as Map<String, dynamic>),
      ),
      GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen()),
      GoRoute(
        path: '/marketplace/:id',
        builder: (_, state) => ProductDetailScreen(product: state.extra as Map<String, dynamic>),
      ),
    ],
  );
});
