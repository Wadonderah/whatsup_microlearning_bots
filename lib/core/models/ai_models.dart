import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

/// AI Message model for chat interactions
@JsonSerializable()
class AIMessage {
  final String id;
  final String content;
  final String role; // 'user', 'assistant', 'system'
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? model;
  final int? tokenCount;
  final double? confidence;

  const AIMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
    this.model,
    this.tokenCount,
    this.confidence,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);
  Map<String, dynamic> toJson() => _$AIMessageToJson(this);

  /// Create user message
  factory AIMessage.user({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      role: 'user',
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Create assistant message
  factory AIMessage.assistant({
    required String id,
    required String content,
    DateTime? timestamp,
    String? model,
    int? tokenCount,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      role: 'assistant',
      timestamp: timestamp ?? DateTime.now(),
      model: model,
      tokenCount: tokenCount,
      confidence: confidence,
      metadata: metadata,
    );
  }

  /// Create system message
  factory AIMessage.system({
    required String id,
    required String content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      role: 'system',
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Check if message is from user
  bool get isUser => role == 'user';

  /// Check if message is from assistant
  bool get isAssistant => role == 'assistant';

  /// Check if message is system message
  bool get isSystem => role == 'system';

  /// Copy with new values
  AIMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? model,
    int? tokenCount,
    double? confidence,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      model: model ?? this.model,
      tokenCount: tokenCount ?? this.tokenCount,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIMessage &&
        other.id == id &&
        other.content == content &&
        other.role == role &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        role.hashCode ^
        timestamp.hashCode;
  }

  @override
  String toString() {
    return 'AIMessage(id: $id, role: $role, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}

/// AI Model information
@JsonSerializable()
class AIModel {
  final String id;
  final String name;
  final String provider;
  final String description;
  final int maxTokens;
  final double costPerToken;
  final bool isAvailable;
  final List<String> capabilities;
  final Map<String, dynamic>? metadata;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.maxTokens,
    required this.costPerToken,
    this.isAvailable = true,
    this.capabilities = const [],
    this.metadata,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);

  /// Check if model supports a capability
  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }

  /// Check if model is suitable for chat
  bool get isChatModel => hasCapability('chat');

  /// Check if model supports function calling
  bool get supportsFunctionCalling => hasCapability('function_calling');

  /// Check if model supports vision
  bool get supportsVision => hasCapability('vision');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIModel &&
        other.id == id &&
        other.name == name &&
        other.provider == provider;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ provider.hashCode;
  }

  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, provider: $provider)';
  }
}

/// AI Chat Session
@JsonSerializable()
class AIChatSession {
  final String id;
  final String userId;
  final String title;
  final List<AIMessage> messages;
  final String? model;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const AIChatSession({
    required this.id,
    required this.userId,
    required this.title,
    this.messages = const [],
    this.model,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  factory AIChatSession.fromJson(Map<String, dynamic> json) => _$AIChatSessionFromJson(json);
  Map<String, dynamic> toJson() => _$AIChatSessionToJson(this);

  /// Get last message
  AIMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get message count
  int get messageCount => messages.length;

  /// Check if session has messages
  bool get hasMessages => messages.isNotEmpty;

  /// Add message to session
  AIChatSession addMessage(AIMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Copy with new values
  AIChatSession copyWith({
    String? id,
    String? userId,
    String? title,
    List<AIMessage>? messages,
    String? model,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AIChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIChatSession &&
        other.id == id &&
        other.userId == userId &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode;
  }

  @override
  String toString() {
    return 'AIChatSession(id: $id, title: $title, messageCount: $messageCount)';
  }
}
