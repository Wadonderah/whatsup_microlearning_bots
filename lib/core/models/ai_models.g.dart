// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => AIMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      model: json['model'] as String?,
      tokenCount: (json['tokenCount'] as num?)?.toInt(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AIMessageToJson(AIMessage instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'role': instance.role,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'model': instance.model,
      'tokenCount': instance.tokenCount,
      'confidence': instance.confidence,
    };

AIModel _$AIModelFromJson(Map<String, dynamic> json) => AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String,
      maxTokens: (json['maxTokens'] as num).toInt(),
      costPerToken: (json['costPerToken'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIModelToJson(AIModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'provider': instance.provider,
      'description': instance.description,
      'maxTokens': instance.maxTokens,
      'costPerToken': instance.costPerToken,
      'isAvailable': instance.isAvailable,
      'capabilities': instance.capabilities,
      'metadata': instance.metadata,
    };

AIChatSession _$AIChatSessionFromJson(Map<String, dynamic> json) =>
    AIChatSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => AIMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      model: json['model'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIChatSessionToJson(AIChatSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'messages': instance.messages,
      'model': instance.model,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };
