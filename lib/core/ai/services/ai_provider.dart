import '../context/attendance_ai_context.dart';
import '../models/ai_response.dart';

abstract class AIProvider {
  Future<AIResponse> askQuestion({
    required AttendanceAIContext context,
    required String question,
  });

  Future<AIResponse> generateAdvice({
    required AttendanceAIContext context,
  });
}
