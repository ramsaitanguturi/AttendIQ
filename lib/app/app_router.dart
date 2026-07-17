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
import '../features/analytics/presentation/pages/reports_page.dart';
import '../features/timetable/presentation/pages/weekly_timetable_page.dart';
import '../features/attendance/presentation/pages/subject_details_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/profile_page.dart';
import '../features/ai_assistant/presentation/pages/ai_assistant_page.dart';

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
        if (isLogin || isRegister) {
          return null; // Stay on login/register
        }
        return '/login'; // Redirect to login from splash or elsewhere
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
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfilePage();
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (BuildContext context, GoRouterState state) {
          return const ReportsPage();
        },
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (BuildContext context, GoRouterState state) {
          return const AIAssistantPage();
        },
      ),
    ],
  );
}

