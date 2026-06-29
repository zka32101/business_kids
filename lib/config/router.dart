import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/child_provider.dart';
import '../screens/auth/login_select_screen.dart';
import '../screens/auth/parent_login_screen.dart';
import '../screens/auth/child_setup_screen.dart';
import '../screens/auth/level_select_screen.dart';
import '../screens/game/home_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/game/bankruptcy_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final selectedChildUid = ref.watch(selectedChildUidProvider);

  return GoRouter(
    initialLocation: '/login-select',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation.startsWith('/login-select') ||
          state.matchedLocation.startsWith('/parent-login');

      if (!isLoggedIn && !isOnAuth) return '/login-select';
      if (isLoggedIn && isOnAuth && selectedChildUid != null) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login-select',
        builder: (context, state) => const LoginSelectScreen(),
      ),
      GoRoute(
        path: '/parent-login',
        builder: (context, state) => const ParentLoginScreen(),
      ),
      GoRoute(
        path: '/child-setup',
        builder: (context, state) => const ChildSetupScreen(),
      ),
      GoRoute(
        path: '/level-select',
        builder: (context, state) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/parent-dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/bankruptcy',
        builder: (context, state) => const BankruptcyScreen(),
      ),
    ],
  );
});
