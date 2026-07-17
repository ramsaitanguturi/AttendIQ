import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/analytics/presentation/pages/dashboard_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/timetable/presentation/pages/weekly_timetable_page.dart';
import '../features/attendance/presentation/pages/subject_details_page.dart';

part 'app_router.g.dart';


@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authControllerProvider);
  final hasSemesterAsync = ref.watch(hasActiveSemesterProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      // 1. If auth is loading, stay on splash or show loading
      if (authState.isLoading) {
        return '/splash';
      }

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.uri.toString();

      final isSplash = location == '/splash';
      final isLogin = location == '/login';
      final isRegister = location == '/register';
      final isOnboarding = location == '/onboarding';

      // 2. Not logged in
      if (!isLoggedIn) {
        if (isSplash || isLogin || isRegister) {
          return null; // Stay on login/register/splash
        }
        return '/login';
      }

      // 3. Logged in - check onboarding (semester status)
      if (hasSemesterAsync.isLoading) {
        return '/splash';
      }

      final hasSemester = hasSemesterAsync.valueOrNull ?? false;

      if (hasSemester) {
        // Setup complete -> Dashboard
        if (isSplash || isLogin || isRegister || isOnboarding) {
          return '/dashboard';
        }
      } else {
        // Onboarding incomplete -> Onboarding page
        if (isSplash || isLogin || isRegister || location == '/dashboard') {
          return '/onboarding';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingPage();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (BuildContext context, GoRouterState state) {
          return const AnalyticsPage();
        },
      ),
      GoRoute(
        path: '/timetable',
        builder: (BuildContext context, GoRouterState state) {
          return const WeeklyTimetablePage();
        },
      ),
      GoRoute(
        path: '/subject/:id',
        builder: (BuildContext context, GoRouterState state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '') ?? 0;
          return SubjectDetailsPage(subjectId: id);
        },
      ),
    ],
  );
}

