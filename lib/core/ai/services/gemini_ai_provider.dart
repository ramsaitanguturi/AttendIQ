import 'dart:convert';
import 'dart:io';
import '../context/attendance_ai_context.dart';
import '../models/ai_response.dart';
import '../prompts/advisor_prompts.dart';
import '../parsers/ai_response_parser.dart';
import 'ai_provider.dart';

class GeminiAIProvider implements AIProvider {
  final String apiKey;

  GeminiAIProvider({required this.apiKey});

  @override
  Future<AIResponse> askQuestion({
    required AttendanceAIContext context,
    required String question,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is empty. Configure GEMINI_API_KEY in compilation variables.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final client = HttpClient();
    try {
      final request = await client.postUrl(url);
      request.headers.contentType = ContentType.json;

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': AdvisorPrompts.systemInstruction}
          ]
        },
        'contents': [
          {
            'parts': [
              {
                'text': AdvisorPrompts.buildPrompt(
                  question,
                  json.encode(context.toJson()),
                )
              }
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        }
      };

      request.write(json.encode(body));
      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('Gemini API status ${response.statusCode}: $errorBody');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final decodedResponse = json.decode(responseBody) as Map<String, dynamic>;
      
      final candidates = decodedResponse['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates returned from Gemini API.');
      }
      
      final content = candidates.first['content'] as Map?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No text parts returned from Gemini API.');
      }

      final rawText = parts.first['text'] as String? ?? '';
      return AIResponseParser.parse(rawText);
    } finally {
      client.close();
    }
  }

  @override
  Future<AIResponse> generateAdvice({
    required AttendanceAIContext context,
  }) async {
    return askQuestion(
      context: context,
      question: 'Give me general academic advisor suggestions and prioritize classes for me based on my current attendance and weekly schedule.',
    );
  }
}
