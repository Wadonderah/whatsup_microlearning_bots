import 'package:json_annotation/json_annotation.dart';

part 'ai_message.g.dart';

@JsonSerializable()
class AIMessage {
  final String id;
  final String content;
  final String role; // 'user', 'assistant', 'system'
  final DateTime timestamp;
  final bool isLoading;
  final String? error;

  const AIMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
    this.error,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);
  Map<String, dynamic> toJson() => _$AIMessageToJson(this);

  // Factory constructors for different message types
  factory AIMessage.user({
    required String content,
    String? id,
  }) {
    return AIMessage(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'user',
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.assistant({
    required String content,
    String? id,
  }) {
    return AIMessage(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'assistant',
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.system({
    required String content,
    String? id,
  }) {
    return AIMessage(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'system',
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.loading({
    String? id,
  }) {
    return AIMessage(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      role: 'assistant',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  // Copy with method for state updates
  AIMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    bool? isLoading,
    String? error,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';
  bool get hasError => error != null;
}
