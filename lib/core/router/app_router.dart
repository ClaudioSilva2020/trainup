import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/onboarding/data/onboarding_repository_impl.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/workout_engine/domain/workout_plan.dart';
import '../../features/workout_session/presentation/session_screen.dart';
import '../../shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      if (authState.isLoading) return '/splash';

      final session = authState.valueOrNull?.session ??
          Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;

      final loc = state.matchedLocation;
      final onPublicRoute =
          loc == '/login' || loc == '/register' || loc == '/splash';

      if (!isAuthenticated && !onPublicRoute) return '/login';

      if (isAuthenticated && onPublicRoute) {
        final userId = session.user.id;
        final repo = OnboardingRepositoryImpl(Supabase.instance.client);
        final profile = await repo.fetchProfile(userId);
        return profile == null ? '/onboarding' : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (ctx, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, _) => LoginScreen(
          onGoToRegister: () => GoRouter.of(ctx).go('/register'),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, _) => RegisterScreen(
          onGoToLogin: () => GoRouter.of(ctx).go('/login'),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, _) => const MainShell(),
      ),
      GoRoute(
        path: '/session',
        builder: (ctx, state) {
          final extra = state.extra as ({WorkoutDay day, String planId});
          return SessionScreen(day: extra.day, planId: extra.planId);
        },
      ),
    ],
  );
});
