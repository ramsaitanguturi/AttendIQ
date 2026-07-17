class AIResponse {
  final String answer;
  final double confidence;
  final List<String> relatedSubjects;
  final List<String> actionItems;

  const AIResponse({
    required this.answer,
    required this.confidence,
    required this.relatedSubjects,
    required this.actionItems,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    // Robust parsing that supports both the standard layout and the legacy warning/recommendation formats.
    String parsedAnswer = '';
    if (json['answer'] != null) {
      parsedAnswer = json['answer'] as String;
    } else if (json['userIntentResolution'] != null && json['userIntentResolution'] is Map) {
      parsedAnswer = (json['userIntentResolution'] as Map)['verdict'] as String? ?? '';
    } else if (json['verdict'] != null) {
      parsedAnswer = json['verdict'] as String;
    }

    final double parsedConfidence = (json['confidence'] as num?)?.toDouble() ?? 0.8;

    final List<String> parsedRelated = [];
    if (json['relatedSubjects'] != null && json['relatedSubjects'] is List) {
      parsedRelated.addAll((json['relatedSubjects'] as List).map((e) => e.toString()));
    } else if (json['criticalWarnings'] != null && json['criticalWarnings'] is List) {
      for (final item in json['criticalWarnings']) {
        if (item is Map && item['title'] != null) {
          parsedRelated.add(item['title'].toString());
        }
      }
    }

    final List<String> parsedActions = [];
    if (json['actionItems'] != null && json['actionItems'] is List) {
      parsedActions.addAll((json['actionItems'] as List).map((e) => e.toString()));
    } else if (json['recommendations'] != null && json['recommendations'] is List) {
      for (final item in json['recommendations']) {
        if (item is Map && item['description'] != null) {
          parsedActions.add(item['description'].toString());
        }
      }
    }

    return AIResponse(
      answer: parsedAnswer,
      confidence: parsedConfidence,
      relatedSubjects: parsedRelated,
      actionItems: parsedActions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'confidence': confidence,
      'relatedSubjects': relatedSubjects,
      'actionItems': actionItems,
    };
  }
}
