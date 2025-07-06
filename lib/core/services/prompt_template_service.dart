import '../models/prompt_template.dart';

class PromptTemplateService {
  static PromptTemplateService? _instance;
  static PromptTemplateService get instance => _instance ??= PromptTemplateService._();
  
  PromptTemplateService._();

  final List<PromptTemplate> _templates = [
    // Learning Templates
    PromptTemplate(
      id: 'learn_topic',
      name: 'Learn New Topic',
      description: 'Get a comprehensive introduction to any topic',
      systemPrompt: '''You are an expert microlearning instructor. Your goal is to teach complex topics in bite-sized, easy-to-understand lessons. Always:
- Break down complex concepts into simple parts
- Use analogies and real-world examples
- Provide actionable insights
- Keep responses concise but comprehensive
- End with a practical tip or next step''',
      userPromptTemplate: 'I want to learn about {topic}. Please provide a beginner-friendly introduction with key concepts and practical examples.',
      placeholders: ['topic'],
      category: PromptCategory.learning,
      icon: '📚',
    ),

    PromptTemplate(
      id: 'explain_concept',
      name: 'Explain Concept',
      description: 'Get detailed explanations of specific concepts',
      systemPrompt: '''You are a skilled educator who excels at explaining complex concepts in simple terms. Focus on:
- Clear, step-by-step explanations
- Using analogies that relate to everyday experiences
- Providing multiple perspectives on the concept
- Including practical applications''',
      userPromptTemplate: 'Please explain the concept of {concept} in simple terms. Include examples and why it\'s important in {context}.',
      placeholders: ['concept', 'context'],
      category: PromptCategory.explanation,
      icon: '💡',
    ),

    // Quiz Templates
    PromptTemplate(
      id: 'create_quiz',
      name: 'Create Quiz',
      description: 'Generate quiz questions on any topic',
      systemPrompt: '''You are a quiz creator specializing in educational assessments. Create engaging, fair, and educational quiz questions that:
- Test understanding, not just memorization
- Include a mix of difficulty levels
- Provide clear, unambiguous questions
- Offer helpful explanations for answers''',
      userPromptTemplate: 'Create a {difficulty} level quiz with {questions} questions about {topic}. Include multiple choice and short answer questions.',
      placeholders: ['difficulty', 'questions', 'topic'],
      category: PromptCategory.quiz,
      icon: '❓',
    ),

    PromptTemplate(
      id: 'practice_problems',
      name: 'Practice Problems',
      description: 'Generate practice exercises and problems',
      systemPrompt: '''You are a practice problem generator. Create realistic, progressively challenging problems that help learners apply their knowledge. Focus on:
- Real-world scenarios
- Step-by-step solutions
- Common mistakes to avoid
- Variations to try''',
      userPromptTemplate: 'Create {number} practice problems for {subject} at {level} level. Include detailed solutions and explanations.',
      placeholders: ['number', 'subject', 'level'],
      category: PromptCategory.practice,
      icon: '🏃',
    ),

    // Summary Templates
    PromptTemplate(
      id: 'summarize_content',
      name: 'Summarize Content',
      description: 'Create concise summaries of complex content',
      systemPrompt: '''You are an expert at creating clear, concise summaries. Your summaries should:
- Capture the most important points
- Maintain logical flow
- Use bullet points for clarity
- Include key takeaways
- Be actionable and memorable''',
      userPromptTemplate: 'Please summarize this content about {topic}: {content}. Focus on the key points and practical applications.',
      placeholders: ['topic', 'content'],
      category: PromptCategory.summary,
      icon: '📝',
    ),

    // General Templates
    PromptTemplate(
      id: 'study_plan',
      name: 'Create Study Plan',
      description: 'Generate personalized study plans',
      systemPrompt: '''You are a learning strategist who creates effective, personalized study plans. Consider:
- Learning objectives and goals
- Available time and resources
- Different learning styles
- Progress tracking methods
- Motivation and engagement strategies''',
      userPromptTemplate: 'Create a {duration} study plan for learning {subject}. I have {time} hours per {frequency} and my goal is {goal}.',
      placeholders: ['duration', 'subject', 'time', 'frequency', 'goal'],
      category: PromptCategory.general,
      icon: '📅',
    ),

    PromptTemplate(
      id: 'learning_tips',
      name: 'Learning Tips',
      description: 'Get personalized learning strategies and tips',
      systemPrompt: '''You are a learning coach who provides practical, evidence-based learning strategies. Focus on:
- Scientifically-backed learning techniques
- Personalized approaches
- Overcoming common learning challenges
- Building effective study habits
- Maintaining motivation''',
      userPromptTemplate: 'I\'m struggling with {challenge} while learning {subject}. My learning style is {style}. What specific strategies can help me?',
      placeholders: ['challenge', 'subject', 'style'],
      category: PromptCategory.general,
      icon: '🎯',
    ),
  ];

  /// Get all available templates
  List<PromptTemplate> getAllTemplates() {
    return List.unmodifiable(_templates.where((t) => t.isActive));
  }

  /// Get templates by category
  List<PromptTemplate> getTemplatesByCategory(PromptCategory category) {
    return _templates
        .where((t) => t.category == category && t.isActive)
        .toList();
  }

  /// Get template by ID
  PromptTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id && t.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Search templates by name or description
  List<PromptTemplate> searchTemplates(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _templates
        .where((t) => 
            t.isActive &&
            (t.name.toLowerCase().contains(lowercaseQuery) ||
             t.description.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  /// Get templates grouped by category
  Map<PromptCategory, List<PromptTemplate>> getTemplatesGroupedByCategory() {
    final Map<PromptCategory, List<PromptTemplate>> grouped = {};
    
    for (final category in PromptCategory.values) {
      grouped[category] = getTemplatesByCategory(category);
    }
    
    return grouped;
  }

  /// Add custom template (for future extensibility)
  void addCustomTemplate(PromptTemplate template) {
    _templates.add(template);
  }

  /// Get popular templates (most commonly used)
  List<PromptTemplate> getPopularTemplates() {
    // For now, return a curated list of popular templates
    final popularIds = ['learn_topic', 'explain_concept', 'create_quiz', 'summarize_content'];
    return popularIds
        .map((id) => getTemplateById(id))
        .where((template) => template != null)
        .cast<PromptTemplate>()
        .toList();
  }
}
