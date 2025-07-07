import 'package:json_annotation/json_annotation.dart';

part 'openrouter_models.g.dart';

@JsonSerializable()
class OpenRouterRequest {
  final String model;
  final List<OpenRouterMessage> messages;
  final double? temperature;
  final int? maxTokens;
  final double? topP;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final bool? stream;

  const OpenRouterRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.stream = false,
  });

  factory OpenRouterRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterRequestToJson(this);
}

@JsonSerializable()
class OpenRouterMessage {
  final String role;
  final String content;

  const OpenRouterMessage({
    required this.role,
    required this.content,
  });

  factory OpenRouterMessage.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterMessageToJson(this);
}

@JsonSerializable()
class OpenRouterResponse {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenRouterChoice> choices;
  final OpenRouterUsage? usage;

  const OpenRouterResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  // Custom converter to handle both string and int IDs from API
  static String _idFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is num) return value.toString();
    return value?.toString() ?? '';
  }

  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterResponseToJson(this);
}

@JsonSerializable()
class OpenRouterChoice {
  final int index;
  final OpenRouterMessage message;
  @JsonKey(fromJson: _finishReasonFromJson)
  final String? finishReason;

  const OpenRouterChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  // Custom converter to handle both string and int finish reasons from API
  static String? _finishReasonFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is num) return value.toString();
    return value?.toString();
  }

  factory OpenRouterChoice.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterChoiceToJson(this);
}

@JsonSerializable()
class OpenRouterUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const OpenRouterUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenRouterUsage.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterUsageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterUsageToJson(this);
}

@JsonSerializable()
class OpenRouterError {
  final String message;
  final String? type;
  final String? code;

  const OpenRouterError({
    required this.message,
    this.type,
    this.code,
  });

  factory OpenRouterError.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterErrorFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterErrorToJson(this);
}

@JsonSerializable()
class OpenRouterErrorResponse {
  final OpenRouterError error;

  const OpenRouterErrorResponse({
    required this.error,
  });

  factory OpenRouterErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterErrorResponseToJson(this);
}
