// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptTemplate _$PromptTemplateFromJson(Map<String, dynamic> json) =>
    PromptTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      systemPrompt: json['systemPrompt'] as String,
      userPromptTemplate: json['userPromptTemplate'] as String,
      placeholders: (json['placeholders'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      category: $enumDecode(_$PromptCategoryEnumMap, json['category']),
      icon: json['icon'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$PromptTemplateToJson(PromptTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'systemPrompt': instance.systemPrompt,
      'userPromptTemplate': instance.userPromptTemplate,
      'placeholders': instance.placeholders,
      'category': _$PromptCategoryEnumMap[instance.category]!,
      'icon': instance.icon,
      'isActive': instance.isActive,
    };

const _$PromptCategoryEnumMap = {
  PromptCategory.learning: 'learning',
  PromptCategory.quiz: 'quiz',
  PromptCategory.explanation: 'explanation',
  PromptCategory.practice: 'practice',
  PromptCategory.summary: 'summary',
  PromptCategory.general: 'general',
};
