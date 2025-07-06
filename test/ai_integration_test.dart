import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/ai_message.dart';
import 'package:whatsup_microlearning_bots/core/models/prompt_template.dart';
import 'package:whatsup_microlearning_bots/core/services/prompt_template_service.dart';

void main() {
  group('AI Integration Tests', () {
    group('AIMessage', () {
      test('should create user message correctly', () {
        final message = AIMessage.user(content: 'Hello, AI!');
        
        expect(message.content, equals('Hello, AI!'));
        expect(message.role, equals('user'));
        expect(message.isUser, isTrue);
        expect(message.isAssistant, isFalse);
        expect(message.isLoading, isFalse);
        expect(message.hasError, isFalse);
      });

      test('should create assistant message correctly', () {
        final message = AIMessage.assistant(content: 'Hello, human!');
        
        expect(message.content, equals('Hello, human!'));
        expect(message.role, equals('assistant'));
        expect(message.isUser, isFalse);
        expect(message.isAssistant, isTrue);
        expect(message.isLoading, isFalse);
        expect(message.hasError, isFalse);
      });

      test('should create loading message correctly', () {
        final message = AIMessage.loading();
        
        expect(message.content, equals(''));
        expect(message.role, equals('assistant'));
        expect(message.isLoading, isTrue);
        expect(message.hasError, isFalse);
      });

      test('should handle error messages correctly', () {
        final message = AIMessage.assistant(content: 'Error occurred')
            .copyWith(error: 'Network error');
        
        expect(message.hasError, isTrue);
        expect(message.error, equals('Network error'));
      });
    });

    group('PromptTemplate', () {
      test('should generate prompt with placeholders correctly', () {
        final template = PromptTemplate(
          id: 'test',
          name: 'Test Template',
          description: 'A test template',
          systemPrompt: 'You are a helpful assistant.',
          userPromptTemplate: 'Explain {topic} in {style} style.',
          placeholders: ['topic', 'style'],
          category: PromptCategory.explanation,
          icon: '💡',
        );

        final values = {'topic': 'AI', 'style': 'simple'};
        final result = template.generatePrompt(values);
        
        expect(result, equals('Explain AI in simple style.'));
      });

      test('should check required values correctly', () {
        final template = PromptTemplate(
          id: 'test',
          name: 'Test Template',
          description: 'A test template',
          systemPrompt: 'You are a helpful assistant.',
          userPromptTemplate: 'Explain {topic} in {style} style.',
          placeholders: ['topic', 'style'],
          category: PromptCategory.explanation,
          icon: '💡',
        );

        final completeValues = {'topic': 'AI', 'style': 'simple'};
        final incompleteValues = {'topic': 'AI'};
        
        expect(template.hasAllRequiredValues(completeValues), isTrue);
        expect(template.hasAllRequiredValues(incompleteValues), isFalse);
      });
    });

    group('PromptTemplateService', () {
      late PromptTemplateService service;

      setUp(() {
        service = PromptTemplateService.instance;
      });

      test('should return all templates', () {
        final templates = service.getAllTemplates();
        expect(templates, isNotEmpty);
        expect(templates.every((t) => t.isActive), isTrue);
      });

      test('should filter templates by category', () {
        final learningTemplates = service.getTemplatesByCategory(PromptCategory.learning);
        expect(learningTemplates.every((t) => t.category == PromptCategory.learning), isTrue);
      });

      test('should find template by ID', () {
        final template = service.getTemplateById('learn_topic');
        expect(template, isNotNull);
        expect(template!.id, equals('learn_topic'));
      });

      test('should search templates by query', () {
        final results = service.searchTemplates('learn');
        expect(results, isNotEmpty);
        expect(results.any((t) => t.name.toLowerCase().contains('learn') || 
                                 t.description.toLowerCase().contains('learn')), isTrue);
      });

      test('should return popular templates', () {
        final popular = service.getPopularTemplates();
        expect(popular, isNotEmpty);
        expect(popular.length, lessThanOrEqualTo(4));
      });

      test('should group templates by category', () {
        final grouped = service.getTemplatesGroupedByCategory();
        expect(grouped.keys.length, equals(PromptCategory.values.length));
        
        for (final category in PromptCategory.values) {
          expect(grouped.containsKey(category), isTrue);
        }
      });
    });

    group('PromptCategory Extension', () {
      test('should return correct display names', () {
        expect(PromptCategory.learning.displayName, equals('Learning'));
        expect(PromptCategory.quiz.displayName, equals('Quiz'));
        expect(PromptCategory.explanation.displayName, equals('Explanation'));
        expect(PromptCategory.practice.displayName, equals('Practice'));
        expect(PromptCategory.summary.displayName, equals('Summary'));
        expect(PromptCategory.general.displayName, equals('General'));
      });

      test('should return correct icons', () {
        expect(PromptCategory.learning.icon, equals('📚'));
        expect(PromptCategory.quiz.icon, equals('❓'));
        expect(PromptCategory.explanation.icon, equals('💡'));
        expect(PromptCategory.practice.icon, equals('🏃'));
        expect(PromptCategory.summary.icon, equals('📝'));
        expect(PromptCategory.general.icon, equals('💬'));
      });
    });
  });
}
