import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ai_message.dart';
import '../../../core/services/ai_service.dart';

// State class for AI chat
class AIChatState {
  final List<AIMessage> messages;
  final bool isLoading;
  final String? error;

  const AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  AIChatState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasError => error != null;
  bool get isEmpty => messages.isEmpty;
  int get messageCount => messages.length;
}

// AI Chat Provider
class AIChatNotifier extends StateNotifier<AIChatState> {
  AIChatNotifier() : super(const AIChatState()) {
    _initializeChat();
  }

  final AIService _aiService = AIService.instance;

  void _initializeChat() {
    // Add welcome message
    final welcomeMessage = AIMessage.system(
      content: '''Welcome to your AI Learning Assistant! 🤖

I'm here to help you learn anything you want. You can:
• Ask me questions about any topic
• Use templates for structured learning
• Get explanations, summaries, and practice problems
• Create personalized study plans

How can I help you learn today?''',
    );

    state = state.copyWith(
      messages: [welcomeMessage],
    );
  }

  /// Send a message to the AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AIMessage.user(content: content.trim());
    final loadingMessage = AIMessage.loading();

    state = state.copyWith(
      messages: [...state.messages, userMessage, loadingMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Send to AI service
      final response = await _aiService.sendMessage(
        messages: [...state.messages.where((m) => !m.isLoading)],
      );

      // Replace loading message with response
      final updatedMessages =
          state.messages.where((m) => m.id != loadingMessage.id).toList();

      updatedMessages.add(response);

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
      );
    } catch (e) {
      // Handle error
      final errorMessage = AIMessage.assistant(
        content: 'Sorry, I encountered an error: ${e.toString()}',
        id: loadingMessage.id,
      ).copyWith(error: e.toString());

      final updatedMessages =
          state.messages.where((m) => m.id != loadingMessage.id).toList();

      updatedMessages.add(errorMessage);

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Retry a failed message
  Future<void> retryMessage(String messageId) async {
    final messageIndex = state.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final failedMessage = state.messages[messageIndex];
    if (!failedMessage.hasError) return;

    // Find the user message that triggered this response
    String? userContent;
    for (int i = messageIndex - 1; i >= 0; i--) {
      if (state.messages[i].isUser) {
        userContent = state.messages[i].content;
        break;
      }
    }

    if (userContent == null) return;

    // Remove the failed message and retry
    final updatedMessages = List<AIMessage>.from(state.messages);
    updatedMessages.removeAt(messageIndex);

    state = state.copyWith(
      messages: updatedMessages,
      error: null,
    );

    // Retry the message
    await sendMessage(userContent);
  }

  /// Clear all messages
  void clearMessages() {
    state = const AIChatState();
    _initializeChat();
  }

  /// Add a system message
  void addSystemMessage(String content) {
    final systemMessage = AIMessage.system(content: content);
    state = state.copyWith(
      messages: [...state.messages, systemMessage],
    );
  }

  /// Get conversation history for context
  List<AIMessage> getConversationHistory({int? limit}) {
    final messages =
        state.messages.where((m) => !m.isLoading && !m.hasError).toList();

    if (limit != null && messages.length > limit) {
      return messages.sublist(messages.length - limit);
    }

    return messages;
  }

  /// Export chat history
  String exportChatHistory() {
    final buffer = StringBuffer();
    buffer.writeln('AI Learning Assistant Chat History');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('=' * 50);

    for (final message in state.messages) {
      if (message.isLoading) continue;

      buffer.writeln();
      buffer.writeln('${message.role.toUpperCase()}: ${message.content}');
      buffer.writeln('Time: ${message.timestamp}');

      if (message.hasError) {
        buffer.writeln('Error: ${message.error}');
      }

      buffer.writeln('-' * 30);
    }

    return buffer.toString();
  }
}

// Provider definition
final aiChatProvider =
    StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier();
});
