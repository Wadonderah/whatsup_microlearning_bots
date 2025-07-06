// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => AIMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AIMessageToJson(AIMessage instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'role': instance.role,
      'timestamp': instance.timestamp.toIso8601String(),
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
