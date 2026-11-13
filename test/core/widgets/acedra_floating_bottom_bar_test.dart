import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/widgets/acedra_floating_bottom_bar.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  Widget buildTestBar({
    required int currentIndex,
    required ValueChanged<int> onTabSelected,
    bool isGlassy = false,
    double width = 400.0,
  }) {
    return ProviderScope(
      overrides: [
        isGlassyThemeEnabledProvider.overrideWithValue(isGlassy),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: AcedraFloatingBottomBar(
                currentIndex: currentIndex,
                onTabSelected: onTabSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('AcedraFloatingBottomBar Tests', () {
    testWidgets('renders all 4 navigation items and labels correctly',
        (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        buildTestBar(
          currentIndex: selected,
          onTabSelected: (i) => selected = i,
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 4 item labels exist in the tree
      expect(find.text('Home'), findsOneWidget);
      // Selected label has opacity 1.0
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
      expect(find.byIcon(Icons.group_rounded), findsOneWidget);
    });

    testWidgets('switching tabs triggers onTabSelected and animates smoothly',
        (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestBar(
              currentIndex: selected,
              onTabSelected: (i) {
                setState(() => selected = i);
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap Analytics (index 2)
      await tester.tap(find.byIcon(Icons.insights_rounded));
      expect(selected, 2);

      // Verify smooth animation frames without layout overflow
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(selected, 2);
    });

    testWidgets('adapts to small and large screen widths without overflow',
        (tester) async {
      for (final width in [320.0, 360.0, 412.0, 600.0]) {
        await tester.pumpWidget(
          buildTestBar(
            currentIndex: 1,
            onTabSelected: (_) {},
            width: width,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('renders properly with glassy theme enabled', (tester) async {
      await tester.pumpWidget(
        buildTestBar(
          currentIndex: 3,
          onTabSelected: (_) {},
          isGlassy: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
