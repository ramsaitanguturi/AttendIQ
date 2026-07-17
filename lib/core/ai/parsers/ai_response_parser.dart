import 'dart:convert';
import '../models/ai_response.dart';

class AIResponseParser {
  AIResponseParser._();

  static AIResponse parse(String rawContent) {
    try {
      // Clean up markdown block wraps or surrounding text by extracting from first '{' to last '}'
      String cleaned = rawContent.trim();
      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }

      final Map<String, dynamic> decoded = json.decode(cleaned) as Map<String, dynamic>;
      return AIResponse.fromJson(decoded);
    } catch (e) {
      // Safe fallback on parsing error
      return AIResponse(
        answer: rawContent.isNotEmpty 
            ? rawContent 
            : 'Sorry, I couldn\'t process the AI recommendation. Please check your data and try again.',
        confidence: 0.5,
        relatedSubjects: const [],
        actionItems: const ['Check subject logs manually'],
      );
    }
  }
}
