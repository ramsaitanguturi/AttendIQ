import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/ai/context/attendance_ai_context.dart';
import '../../../../core/ai/context/ai_context_builder.dart';
import '../../../../core/ai/models/ai_response.dart';
import '../../../../core/ai/services/ai_provider.dart';
import '../../../../core/ai/services/gemini_ai_provider.dart';
import '../../../../core/ai/services/local_advisor_service.dart';

part 'ai_chat_controller.g.dart';

enum MessageSender {
  user,
  assistant,
}

class ChatMessage {
  final String text;
  final MessageSender sender;
  final AIResponse? responseDetails;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    this.responseDetails,
    required this.timestamp,
  });
}

class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  AIChatState({
    required this.messages,
    required this.isLoading,
    this.error,
    required this.isOffline,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isOffline,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

@riverpod
class AIChatController extends _$AIChatController {
  @override
  FutureOr<AIChatState> build() async {
    final initialMessage = ChatMessage(
      text: "Hello! I am the AttendIQ Advisor, your personal academic counselor. Ask me questions like:\n• 'Can I skip tomorrow\'s classes?'\n• 'Which subjects are risky?'\n• 'How many classes do I need to attend?'",
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );

    final connectivityResult = await Connectivity().checkConnectivity();
    // Checks if none of the active networks are connected, meaning offline.
    final isOffline = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;

    return AIChatState(
      messages: [initialMessage],
      isLoading: false,
      isOffline: isOffline,
    );
  }

  Future<void> askQuestion(String question) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoading) return;

    final userMsg = ChatMessage(
      text: question,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = AsyncData(currentState.copyWith(
      messages: [...currentState.messages, userMsg],
      isLoading: true,
      error: null,
    ));

    try {
      final context = await ref.read(aiContextProvider.future);
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;
      
      final String envApiKey = const String.fromEnvironment('GEMINI_API_KEY');
      
      AIProvider provider;
      if (isOffline || envApiKey.isEmpty) {
        provider = const LocalAdvisorService();
      } else {
        provider = GeminiAIProvider(apiKey: envApiKey);
      }

      final response = await provider.askQuestion(context: context, question: question);

      final assistantMsg = ChatMessage(
        text: response.answer,
        sender: MessageSender.assistant,
        responseDetails: response,
        timestamp: DateTime.now(),
      );

      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncData(updatedState.copyWith(
          messages: [...updatedState.messages, assistantMsg],
          isLoading: false,
          isOffline: isOffline,
        ));
      }
    } catch (e) {
      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncData(updatedState.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  Future<void> clearChat() async {
    final initialMessage = ChatMessage(
      text: "Hello! I am the AttendIQ Advisor, your personal academic counselor. Ask me questions like:\n• 'Can I skip tomorrow\'s classes?'\n• 'Which subjects are risky?'\n• 'How many classes do I need to attend?'",
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;

    state = AsyncData(AIChatState(
      messages: [initialMessage],
      isLoading: false,
      isOffline: isOffline,
    ));
  }
}
