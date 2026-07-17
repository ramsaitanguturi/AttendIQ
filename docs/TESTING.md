# Testing Framework: AttendIQ

This document details the strategies, libraries, patterns, and guidelines for testing the AttendIQ application.

---

## 1. Testing Structure

AttendIQ partitions testing into three categories matching the Flutter standard:
1. **Unit Tests**: Test business logic, DTO mappings, calculations, and sync logic.
2. **Widget Tests**: Test visual rendering, state overrides, and user interaction triggers.
3. **Integration Tests**: End-to-end user journeys (e.g., Onboarding -> Dashboard -> Add Subject) tested on emulator or physical devices.

```
test/
├── features/
│   ├── subject/
│   │   ├── domain/
│   │   │   └── calculate_subject_stats_test.dart  # Unit tests for calculations
│   │   └── presentation/
│   │       └── subject_detail_page_test.dart     # Widget tests with mocked data
│   └── auth/
│       └── data/
│           └── auth_repository_test.dart         # Mocked unit tests
│
└── mocks/
    └── mock_repositories.dart                    # Centralized mock definitions
```

---

## 2. Unit Testing & Mocking (Mocktail)

We use the **`mocktail`** package for mocking because it provides type-safe mock setups without requiring manual code generation.

### 2.1 Central Mock Definitions
Create a file at `test/mocks/mock_repositories.dart` containing all mocks:
```dart
import 'package:mocktail/mocktail.dart';
import 'package:AttendIQ/features/subject/domain/repositories/subject_repository.dart';
import 'package:AttendIQ/features/attendance/domain/repositories/attendance_repository.dart';

class MockSubjectRepository extends Mock implements SubjectRepository {}
class MockAttendanceRepository extends Mock implements AttendanceRepository {}
```

### 2.2 Example: Unit Test for Bunk Calculator Math
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:AttendIQ/core/utils/attendance_math.dart';

void main() {
  group('Attendance Math Calculators', () {
    test('Calculates correct attendance percentage', () {
      final percentage = AttendanceMath.calculatePercentage(
        present: 15,
        absent: 5,
        lateCount: 2,
        lateWeight: 0.5,
      );
      expect(percentage, equals(80.0)); // (15 + 1) / 20 * 100 = 80.0
    });

    test('Calculates safe bunks correctly', () {
      // 15 present, 5 absent, target 75%
      // 15 / (20 + B) >= 0.75 => B <= (15 - 15) / 0.75 = 0
      final safeBunks = AttendanceMath.calculateSafeBunks(
        present: 15,
        absent: 5,
        target: 75.0,
      );
      expect(safeBunks, equals(0));
      
      // 18 present, 2 absent, target 75%
      // 18 / (20 + B) >= 0.75 => B <= (18 - 15) / 0.75 = 4
      final safeBunksHigh = AttendanceMath.calculateSafeBunks(
        present: 18,
        absent: 2,
        target: 75.0,
      );
      expect(safeBunksHigh, equals(4));
    });

    test('Calculates must attend correctly', () {
      // 10 present, 10 absent, target 75%
      // (10 + A) / (20 + A) >= 0.75 => A >= (15 - 10) / 0.25 = 20
      final mustAttend = AttendanceMath.calculateMustAttend(
        present: 10,
        absent: 10,
        target: 75.0,
      );
      expect(mustAttend, equals(20));
    });
  });
}
```

---

## 3. Widget Testing with Riverpod Overrides

When testing UI elements, you must override repositories or database providers to avoid hits to Isar or Firebase.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:AttendIQ/features/subject/domain/repositories/subject_repository.dart';
import 'package:AttendIQ/features/subject/presentation/pages/subject_list_page.dart';

void main() {
  late MockSubjectRepository mockSubjectRepository;

  setUp(() {
    mockSubjectRepository = MockSubjectRepository();
  });

  testWidgets('Renders subject list page with mocked content', (tester) async {
    // Arrange: Set up mock behavior
    when(() => mockSubjectRepository.fetchSubjects()).thenAnswer(
      (_) async => [
        Subject(id: 1, name: 'Maths', credits: 4, colorHex: '#FF5733'),
      ],
    );

    // Act: Pump widget overriding the repository provider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subjectRepositoryProvider.overrideWithValue(mockSubjectRepository),
        ],
        child: const MaterialApp(
          home: SubjectListPage(),
        ),
      ),
    );

    // Assert: Verify loading state then final lists are drawn
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle(); // Let animations run
    expect(find.text('Maths'), findsOneWidget);
  });
}
```

---

## 4. Integration Testing (E2E)

Integration tests execute on a device using mock environment drivers.

File: `integration_test/app_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:AttendIQ/main_development.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full End to End Onboarding Flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Verify Onboarding Screen is visible
    expect(find.text('Create your Active Semester'), findsOneWidget);

    // Enter details and tap next
    await tester.enterText(find.byKey(const Key('semester_name_field')), 'Fall 2026');
    await tester.tap(find.byKey(const Key('wizard_next_button')));
    await tester.pumpAndSettle();

    // Confirm redirected to Dashboard
    expect(find.text('Overall Attendance'), findsOneWidget);
  });
}
```
To execute integration tests, run:
`flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart`
