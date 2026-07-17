import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/ai_chat_controller.dart';

class AIAssistantPage extends ConsumerStatefulWidget {
  const AIAssistantPage({super.key});

  @override
  ConsumerState<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends ConsumerState<AIAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _suggestedQuestions = [
    "Can I skip tomorrow's classes?",
    "What happens if I miss two classes?",
    "Which subjects are risky?",
    "How many classes do I need to attend?",
    "Should I attend today's DBMS class?",
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(aIChatControllerProvider.notifier).askQuestion(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatStateAsync = ref.watch(aIChatControllerProvider);

    // Listen to changes to scroll to bottom when new messages arrive
    ref.listen(aIChatControllerProvider, (prev, next) {
      if (next.hasValue && next.value != null) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.deepPurpleAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AttendIQ Advisor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                chatStateAsync.when(
                  data: (state) => Text(
                    state.isOffline ? 'Offline - Local Rules' : 'Online - Gemini AI',
                    style: TextStyle(
                      fontSize: 11,
                      color: state.isOffline ? AppColors.attendanceLow : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const Text('Initializing...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  error: (_, __) => const Text('Error', style: TextStyle(fontSize: 11, color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat',
            onPressed: () => ref.read(aIChatControllerProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: chatStateAsync.when(
        data: (chatState) {
          return Column(
            children: [
              // Offline/Local Mode Notice Banner
              if (chatState.isOffline)
                Container(
                  width: double.infinity,
                  color: AppColors.attendanceLow.withOpacity(0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, size: 16, color: AppColors.attendanceLow),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Offline Mode Active. Advice is calculated locally using deterministic rule sets.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatState.messages[index];
                    return _buildMessageBubble(message, isDark);
                  },
                ),
              ),

              // Error Display
              if (chatState.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.attendanceLow.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.attendanceLow.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.attendanceLow),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            chatState.error!,
                            style: const TextStyle(fontSize: 12, color: AppColors.attendanceLow),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading Shimmer or pulsing text
              if (chatState.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTypingIndicator(isDark),
                  ),
                ),

              // Suggested Questions Scrolling horizontal chips
              if (chatState.messages.length <= 1 && !chatState.isLoading) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Suggested Questions:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _suggestedQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _suggestedQuestions[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            question,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          surfaceTintColor: Colors.transparent,
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          onPressed: () => _handleSubmit(question),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 12),

              // Chat Input text field
              _buildInputArea(isDark, chatState.isLoading),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.deepPurpleAccent),
              SizedBox(height: 16),
              Text('Warming up advisor system...'),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Text('Initialization Error: $err', style: const TextStyle(color: AppColors.attendanceLow)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.sender == MessageSender.user;
    final details = message.responseDetails;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.deepPurpleAccent
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isUser
                          ? Colors.black
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      height: 1.35,
                    ),
                  ),
                ),
                
                // Extra UI elements for the AI response details
                if (details != null && !isUser) ...[
                  const SizedBox(height: 8),
                  
                  // Related Subjects chips
                  if (details.relatedSubjects.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: details.relatedSubjects.map((sub) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                          ),
                          child: Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Action items card
                  if (details.actionItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.playlist_add_check, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Actionable Recommendations',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...details.actionItems.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(Icons.arrow_right, size: 14, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Analyzing attendance metrics...',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurpleAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _textController,
                    readOnly: isLoading,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: (text) => _handleSubmit(text),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black, size: 20),
                onPressed: isLoading ? null : () => _handleSubmit(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
