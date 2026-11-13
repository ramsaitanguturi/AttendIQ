import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/app/app.dart';

void main() {
  testWidgets('ACEDRA App bootstrap smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame inside ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: AttendIQApp(),
      ),
    );

    // Verify that the Splash Screen is rendered and displays 'ACEDRA'
    expect(find.text('ACEDRA'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
