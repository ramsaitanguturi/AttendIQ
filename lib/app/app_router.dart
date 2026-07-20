import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/semester/presentation/controllers/semester_controller.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/analytics/presentation/pages/dashboard_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/analytics/presentation/pages/reports_page.dart';
import '../features/timetable/presentation/pages/weekly_timetable_page.dart';
import '../features/attendance/presentation/pages/subject_details_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/about_page.dart';
import '../features/backup/presentation/pages/backup_page.dart';
import '../features/ai_assistant/presentation/pages/ai_assistant_page.dart';

import '../features/academic_planner/presentation/pages/academic_planner_page.dart';
import '../features/widgets/presentation/pages/widget_settings_page.dart';

part 'app_router.g.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(hasActiveSemesterProvider, (previous, next) {
      notifyListeners();
    });
  }
}

@Riverpod(keepAlive: true)
RouterNotifier routerNotifier(RouterNotifierRef ref) {
  return RouterNotifier(ref);
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final hasSemesterAsync = ref.read(hasActiveSemesterProvider);

      if (hasSemesterAsync.isLoading) {
        return '/splash';
      }

      final hasSemester = hasSemesterAsync.valueOrNull ?? false;
      final location = state.uri.toString();

      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';

      if (hasSemester) {
        if (isSplash || isOnboarding) {
          return '/dashboard';
        }
      } else {
        if (isSplash || location == '/dashboard') {
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
        path: '/backup',
        builder: (BuildContext context, GoRouterState state) {
          return const BackupPage();
        },
      ),
      GoRoute(
        path: '/about',
        builder: (BuildContext context, GoRouterState state) {
          return const AboutPage();
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
      GoRoute(
        path: '/planner',
        builder: (BuildContext context, GoRouterState state) {
          return const AcademicPlannerPage();
        },
      ),
      GoRoute(
        path: '/widget-settings',
        builder: (BuildContext context, GoRouterState state) {
          return const WidgetSettingsPage();
        },
      ),
    ],
  );
}
