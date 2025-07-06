// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openrouter_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenRouterRequest _$OpenRouterRequestFromJson(Map<String, dynamic> json) =>
    OpenRouterRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => OpenRouterMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1000,
      topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
      stream: json['stream'] as bool? ?? false,
    );

Map<String, dynamic> _$OpenRouterRequestToJson(OpenRouterRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'topP': instance.topP,
      'frequencyPenalty': instance.frequencyPenalty,
      'presencePenalty': instance.presencePenalty,
      'stream': instance.stream,
    };

OpenRouterMessage _$OpenRouterMessageFromJson(Map<String, dynamic> json) =>
    OpenRouterMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$OpenRouterMessageToJson(OpenRouterMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

OpenRouterResponse _$OpenRouterResponseFromJson(Map<String, dynamic> json) =>
    OpenRouterResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => OpenRouterChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] == null
          ? null
          : OpenRouterUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenRouterResponseToJson(OpenRouterResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.usage,
    };

OpenRouterChoice _$OpenRouterChoiceFromJson(Map<String, dynamic> json) =>
    OpenRouterChoice(
      index: (json['index'] as num).toInt(),
      message:
          OpenRouterMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finishReason'] as String?,
    );

Map<String, dynamic> _$OpenRouterChoiceToJson(OpenRouterChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message,
      'finishReason': instance.finishReason,
    };

OpenRouterUsage _$OpenRouterUsageFromJson(Map<String, dynamic> json) =>
    OpenRouterUsage(
      promptTokens: (json['promptTokens'] as num).toInt(),
      completionTokens: (json['completionTokens'] as num).toInt(),
      totalTokens: (json['totalTokens'] as num).toInt(),
    );

Map<String, dynamic> _$OpenRouterUsageToJson(OpenRouterUsage instance) =>
    <String, dynamic>{
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
      'totalTokens': instance.totalTokens,
    };

OpenRouterError _$OpenRouterErrorFromJson(Map<String, dynamic> json) =>
    OpenRouterError(
      message: json['message'] as String,
      type: json['type'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$OpenRouterErrorToJson(OpenRouterError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'type': instance.type,
      'code': instance.code,
    };

OpenRouterErrorResponse _$OpenRouterErrorResponseFromJson(
        Map<String, dynamic> json) =>
    OpenRouterErrorResponse(
      error: OpenRouterError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenRouterErrorResponseToJson(
        OpenRouterErrorResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
    };
