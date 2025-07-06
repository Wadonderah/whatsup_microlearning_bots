import 'package:json_annotation/json_annotation.dart';

part 'prompt_template.g.dart';

@JsonSerializable()
class PromptTemplate {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String userPromptTemplate;
  final List<String> placeholders;
  final PromptCategory category;
  final String icon;
  final bool isActive;

  const PromptTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.userPromptTemplate,
    required this.placeholders,
    required this.category,
    required this.icon,
    this.isActive = true,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) => 
      _$PromptTemplateFromJson(json);
  
  Map<String, dynamic> toJson() => _$PromptTemplateToJson(this);

  /// Generate the actual prompt by replacing placeholders
  String generatePrompt(Map<String, String> values) {
    String prompt = userPromptTemplate;
    
    for (final placeholder in placeholders) {
      final value = values[placeholder] ?? '';
      prompt = prompt.replaceAll('{$placeholder}', value);
    }
    
    return prompt;
  }

  /// Check if all required placeholders are provided
  bool hasAllRequiredValues(Map<String, String> values) {
    return placeholders.every((placeholder) => 
        values.containsKey(placeholder) && values[placeholder]!.isNotEmpty);
  }

  PromptTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    String? userPromptTemplate,
    List<String>? placeholders,
    PromptCategory? category,
    String? icon,
    bool? isActive,
  }) {
    return PromptTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      userPromptTemplate: userPromptTemplate ?? this.userPromptTemplate,
      placeholders: placeholders ?? this.placeholders,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum PromptCategory {
  @JsonValue('learning')
  learning,
  @JsonValue('quiz')
  quiz,
  @JsonValue('explanation')
  explanation,
  @JsonValue('practice')
  practice,
  @JsonValue('summary')
  summary,
  @JsonValue('general')
  general,
}

extension PromptCategoryExtension on PromptCategory {
  String get displayName {
    switch (this) {
      case PromptCategory.learning:
        return 'Learning';
      case PromptCategory.quiz:
        return 'Quiz';
      case PromptCategory.explanation:
        return 'Explanation';
      case PromptCategory.practice:
        return 'Practice';
      case PromptCategory.summary:
        return 'Summary';
      case PromptCategory.general:
        return 'General';
    }
  }

  String get icon {
    switch (this) {
      case PromptCategory.learning:
        return '📚';
      case PromptCategory.quiz:
        return '❓';
      case PromptCategory.explanation:
        return '💡';
      case PromptCategory.practice:
        return '🏃';
      case PromptCategory.summary:
        return '📝';
      case PromptCategory.general:
        return '💬';
    }
  }
}
