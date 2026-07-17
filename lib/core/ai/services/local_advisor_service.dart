import '../context/attendance_ai_context.dart';
import '../models/ai_response.dart';
import 'ai_provider.dart';

class LocalAdvisorService implements AIProvider {
  const LocalAdvisorService();

  @override
  Future<AIResponse> askQuestion({
    required AttendanceAIContext context,
    required String question,
  }) async {
    final normalized = question.toLowerCase();

    // 1. "Can I skip tomorrow's classes?"
    if (normalized.contains('skip tomorrow') || normalized.contains("tomorrow's classes")) {
      final tomorrowClasses = context.upcomingClasses.where((c) => c['day'] == 'Tomorrow').toList();
      if (tomorrowClasses.isEmpty) {
        return const AIResponse(
          answer: 'You do not have any classes scheduled for tomorrow, so you are free to take a break!',
          confidence: 1.0,
          relatedSubjects: [],
          actionItems: ['Enjoy your day off!'],
        );
      }

      final List<String> riskyTomorrow = [];
      final List<String> safeTomorrow = [];
      final List<String> actions = [];

      for (final cl in tomorrowClasses) {
        final subjectId = cl['subjectId'] as int?;
        final subjectName = cl['subjectName'] as String? ?? 'Subject';
        
        final stat = context.subjectStatistics.firstWhere(
          (s) => s['id'] == subjectId,
          orElse: () => {},
        );

        if (stat.isNotEmpty) {
          final percentage = stat['currentPercentage'] as double? ?? 100.0;
          final target = stat['attendanceTarget'] as double? ?? 75.0;
          final safeBunks = stat['safeBunks'] as int? ?? 0;

          if (percentage < target || safeBunks <= 0) {
            riskyTomorrow.add(subjectName);
            actions.add('Attend $subjectName (Current: ${percentage.toStringAsFixed(1)}% < Target: ${target.toStringAsFixed(0)}%)');
          } else {
            safeTomorrow.add('$subjectName ($safeBunks skips left)');
          }
        }
      }

      if (riskyTomorrow.isNotEmpty) {
        return AIResponse(
          answer: 'No, you should not skip tomorrow\'s classes. You have critical attendance in: ${riskyTomorrow.join(', ')}.',
          confidence: 1.0,
          relatedSubjects: riskyTomorrow,
          actionItems: actions,
        );
      } else {
        return AIResponse(
          answer: 'Yes, you can safely skip tomorrow\'s classes: ${safeTomorrow.join(', ')}.',
          confidence: 1.0,
          relatedSubjects: tomorrowClasses.map((c) => c['subjectName'] as String).toList(),
          actionItems: const ['Make sure to log your attendance accurately.'],
        );
      }
    }

    // 2. "What happens if I miss two classes?"
    if (normalized.contains('miss two') || normalized.contains('miss 2')) {
      final List<String> warnings = [];
      final List<String> related = [];

      for (final stat in context.subjectStatistics) {
        final subjectName = stat['name'] as String? ?? 'Subject';
        final present = stat['present'] as int? ?? 0;
        final total = stat['total'] as int? ?? 0;
        final target = stat['attendanceTarget'] as double? ?? 75.0;

        final newTotal = total + 2;
        final newPercentage = newTotal > 0 ? (present / newTotal) * 100.0 : 100.0;

        if (newPercentage < target) {
          warnings.add('In $subjectName, attendance drops from ${stat['currentPercentage']?.toStringAsFixed(1)}% to ${newPercentage.toStringAsFixed(1)}%, which is below your target of ${target.toStringAsFixed(0)}%.');
          related.add(subjectName);
        }
      }

      if (warnings.isNotEmpty) {
        return AIResponse(
          answer: 'Missing two classes will drop you below your threshold in some subjects. Avoid doing this.',
          confidence: 1.0,
          relatedSubjects: related,
          actionItems: warnings,
        );
      } else {
        return const AIResponse(
          answer: 'You are currently in the safe zone. Missing two classes will not drop you below the required attendance target in any subject.',
          confidence: 1.0,
          relatedSubjects: [],
          actionItems: ['You can safely miss classes if needed, but monitor your margin.'],
        );
      }
    }

    // 3. "Which subjects are risky?"
    if (normalized.contains('risky') || normalized.contains('risk') || normalized.contains('danger') || normalized.contains('critical')) {
      final criticalList = context.riskSubjects.where((r) => r['status'] == 'Critical').toList();
      final warningList = context.riskSubjects.where((r) => r['status'] == 'Warning').toList();

      if (criticalList.isEmpty && warningList.isEmpty) {
        return const AIResponse(
          answer: 'All your subjects are currently in the safe zone. Keep up the good work!',
          confidence: 1.0,
          relatedSubjects: [],
          actionItems: ['Maintain your current attendance habits.'],
        );
      }

      final List<String> related = [];
      final List<String> actions = [];

      for (final c in criticalList) {
        final name = c['name'] as String;
        related.add(name);
        actions.add('Critical: $name is at ${c['currentPercentage']?.toStringAsFixed(1)}% (needs ${c['mustAttendConsecutive']} consecutive classes)');
      }

      for (final w in warningList) {
        final name = w['name'] as String;
        related.add(name);
        actions.add('Warning: $name is at ${w['currentPercentage']?.toStringAsFixed(1)}% (only ${w['safeBunks']} safe skips remaining)');
      }

      return AIResponse(
        answer: 'You have ${criticalList.length} critical and ${warningList.length} warning subjects.',
        confidence: 1.0,
        relatedSubjects: related,
        actionItems: actions,
      );
    }

    // 4. "How many classes do I need to attend?"
    if (normalized.contains('how many classes') || normalized.contains('need to attend') || normalized.contains('consecutive')) {
      final List<String> items = [];
      final List<String> related = [];

      for (final stat in context.subjectStatistics) {
        final must = stat['mustAttendConsecutive'] as int? ?? 0;
        final name = stat['name'] as String? ?? 'Subject';
        final target = stat['attendanceTarget'] as double? ?? 75.0;

        if (must > 0) {
          items.add('Attend $must consecutive classes in $name to restore attendance to ${target.toStringAsFixed(0)}%.');
          related.add(name);
        }
      }

      if (items.isNotEmpty) {
        return AIResponse(
          answer: 'Here is the number of consecutive classes you must attend to recover your attendance:',
          confidence: 1.0,
          relatedSubjects: related,
          actionItems: items,
        );
      } else {
        return const AIResponse(
          answer: 'You are currently above your attendance target for all subjects. You do not need to attend any consecutive catch-up classes.',
          confidence: 1.0,
          relatedSubjects: [],
          actionItems: ['Keep maintaining your current attendance!'],
        );
      }
    }

    // 5. "Should I attend today's [Subject] class?"
    final todayClasses = context.upcomingClasses.where((c) => c['day'] == 'Today').toList();
    
    // Check if the user is asking about a specific subject in today's classes
    Map<String, dynamic>? matchClass;
    for (final cl in todayClasses) {
      final name = (cl['subjectName'] as String? ?? '').toLowerCase();
      if (normalized.contains(name) || (name.contains('dbms') && normalized.contains('dbms'))) {
        matchClass = cl;
        break;
      }
    }

    if (matchClass != null) {
      final subjectId = matchClass['subjectId'] as int?;
      final subjectName = matchClass['subjectName'] as String? ?? 'Subject';

      final stat = context.subjectStatistics.firstWhere(
        (s) => s['id'] == subjectId,
        orElse: () => {},
      );

      if (stat.isNotEmpty) {
        final percentage = stat['currentPercentage'] as double? ?? 100.0;
        final target = stat['attendanceTarget'] as double? ?? 75.0;
        final safeBunks = stat['safeBunks'] as int? ?? 0;

        if (percentage < target || safeBunks <= 0) {
          return AIResponse(
            answer: 'Yes, you must attend today\'s $subjectName class. Attendance in this subject is critical.',
            confidence: 1.0,
            relatedSubjects: [subjectName],
            actionItems: ['Skipping today will drop your attendance to critical levels.'],
          );
        } else {
          return AIResponse(
            answer: 'You can safely skip today\'s $subjectName class if you have an emergency. You have $safeBunks safe skips remaining.',
            confidence: 1.0,
            relatedSubjects: [subjectName],
            actionItems: ['Skipping will drop your attendance slightly, but it will remain above target.'],
          );
        }
      }
    } else if (normalized.contains('should i attend') && todayClasses.isNotEmpty) {
      // General question about today's classes
      final List<String> risky = [];
      final List<String> actions = [];

      for (final cl in todayClasses) {
        final subjectId = cl['subjectId'] as int?;
        final subjectName = cl['subjectName'] as String? ?? 'Subject';
        final stat = context.subjectStatistics.firstWhere((s) => s['id'] == subjectId, orElse: () => {});

        if (stat.isNotEmpty) {
          final percentage = stat['currentPercentage'] as double? ?? 100.0;
          final target = stat['attendanceTarget'] as double? ?? 75.0;
          final safeBunks = stat['safeBunks'] as int? ?? 0;

          if (percentage < target || safeBunks <= 0) {
            risky.add(subjectName);
            actions.add('Must attend: $subjectName (Current: ${percentage.toStringAsFixed(1)}% < Target: ${target.toStringAsFixed(0)}%)');
          } else {
            actions.add('Optional: $subjectName (Safe skips: $safeBunks)');
          }
        }
      }

      if (risky.isNotEmpty) {
        return AIResponse(
          answer: 'You should attend today\'s classes. Subjects like ${risky.join(', ')} require your attention.',
          confidence: 1.0,
          relatedSubjects: risky,
          actionItems: actions,
        );
      } else {
        return AIResponse(
          answer: 'You can safely skip today\'s classes if needed. All scheduled subjects have safe skips available.',
          confidence: 1.0,
          relatedSubjects: todayClasses.map((c) => c['subjectName'] as String).toList(),
          actionItems: actions,
        );
      }
    }

    // Default fallback: general advice
    return generateAdvice(context: context);
  }

  @override
  Future<AIResponse> generateAdvice({
    required AttendanceAIContext context,
  }) async {
    final List<String> actionItems = [];
    final List<String> related = [];

    // Rule 1: Below threshold
    for (final stat in context.subjectStatistics) {
      final percentage = stat['currentPercentage'] as double? ?? 100.0;
      final target = stat['attendanceTarget'] as double? ?? 75.0;
      final must = stat['mustAttendConsecutive'] as int? ?? 0;
      final name = stat['name'] as String? ?? 'Subject';

      if (percentage < target) {
        actionItems.add('Must attend $name to reach ${target.toStringAsFixed(0)}%. You need $must consecutive classes.');
        related.add(name);
      }
    }

    // Rule 2: Near threshold (Warning)
    for (final stat in context.subjectStatistics) {
      final percentage = stat['currentPercentage'] as double? ?? 100.0;
      final target = stat['attendanceTarget'] as double? ?? 75.0;
      final name = stat['name'] as String? ?? 'Subject';

      if (percentage >= target && (percentage - target <= 2.5)) {
        actionItems.add('Alert: $name is close to falling below target. You can only skip 0 classes.');
        related.add(name);
      }
    }

    // Rule 3: Safe Skips Summary
    for (final stat in context.subjectStatistics) {
      final safeBunks = stat['safeBunks'] as int? ?? 0;
      final name = stat['name'] as String? ?? 'Subject';

      if (safeBunks > 0) {
        actionItems.add('You have $safeBunks safe skips remaining in $name.');
        related.add(name);
      }
    }

    if (actionItems.isEmpty) {
      actionItems.add('Keep logging classes to generate trends.');
    }

    return AIResponse(
      answer: 'Here is your local rule-based attendance recommendation. You are currently offline or Gemini is unavailable.',
      confidence: 1.0,
      relatedSubjects: related,
      actionItems: actionItems.take(3).toList(), // Limit to 3 items as per AI_AGENT instructions
    );
  }
}
