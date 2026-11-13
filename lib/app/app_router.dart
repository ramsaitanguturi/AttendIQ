import 'package:flutter/foundation.dart';
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
import '../features/account/presentation/pages/account_page.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';
import '../core/widgets/acedra_floating_bottom_bar.dart';
import '../core/theme/colors.dart';

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
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final hasSemesterAsync = ref.read(hasActiveSemesterProvider);

      if (hasSemesterAsync.isLoading) {
        return '/splash';
      }

      final location = state.uri.path;

      if (hasSemesterAsync.hasError) {
        if (location == '/error') {
          return null;
        }
        final err = hasSemesterAsync.error?.toString() ??
            'Failed to load active semester.';
        return '/error?message=${Uri.encodeComponent(err)}';
      }

      if (location == '/error') {
        return '/splash';
      }

      final hasSemester = hasSemesterAsync.valueOrNull ?? false;
      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';

      if (hasSemester) {
        if (isSplash || isOnboarding) {
          return '/dashboard';
        }
      } else {
        if (!isOnboarding) {
          return '/onboarding';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/error',
        builder: (BuildContext context, GoRouterState state) {
          final errorMsg = state.uri.queryParameters['message'] ??
              'A database or initialization error occurred.';
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.attendanceLow,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to initialize semester data',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMsg,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(hasActiveSemesterProvider);
                        ref.invalidate(activeSemesterProvider);
                        context.go('/splash');
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return Scaffold(
            body: Stack(
              children: [
                navigationShell,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AcedraFloatingBottomBar(
                    currentIndex: navigationShell.currentIndex,
                    onTabSelected: (index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/dashboard',
                builder: (BuildContext context, GoRouterState state) {
                  return DashboardPage(
                    initialSection: state.uri.queryParameters['section'],
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/timetable',
                builder: (BuildContext context, GoRouterState state) {
                  return const WeeklyTimetablePage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/analytics',
                builder: (BuildContext context, GoRouterState state) {
                  return const AnalyticsPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/account',
                builder: (BuildContext context, GoRouterState state) {
                  return const AccountPage();
                },
              ),
            ],
          ),
        ],
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
        redirect: (BuildContext context, GoRouterState state) {
          final isEnabled = ref.read(isAiAdvisorEnabledProvider);
          if (!isEnabled) {
            return '/dashboard';
          }
          return null;
        },
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
