/// Utility class for AI model selection and recommendations
class ModelSelector {
  static const Map<String, ModelProfile> _modelProfiles = {
    'openai/gpt-3.5-turbo': ModelProfile(
      id: 'openai/gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      provider: 'OpenAI',
      tier: ModelTier.standard,
      speed: ModelSpeed.fast,
      cost: ModelCost.low,
      capabilities: [ModelCapability.chat, ModelCapability.completion],
      maxTokens: 4096,
      description: 'Fast and efficient for most conversational tasks',
      bestFor: ['Quick responses', 'General chat', 'Simple explanations'],
      limitations: ['Limited context window', 'No multimodal support'],
    ),
    'openai/gpt-4': ModelProfile(
      id: 'openai/gpt-4',
      name: 'GPT-4',
      provider: 'OpenAI',
      tier: ModelTier.premium,
      speed: ModelSpeed.medium,
      cost: ModelCost.high,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.completion,
        ModelCapability.analysis,
        ModelCapability.reasoning
      ],
      maxTokens: 8192,
      description: 'Most capable model for complex reasoning and analysis',
      bestFor: ['Complex problem solving', 'Detailed analysis', 'Code review'],
      limitations: ['Higher cost', 'Slower responses'],
    ),
    'openai/chatgpt-4o-latest': ModelProfile(
      id: 'openai/chatgpt-4o-latest',
      name: 'ChatGPT-4o Latest',
      provider: 'OpenAI',
      tier: ModelTier.premium,
      speed: ModelSpeed.fast,
      cost: ModelCost.medium,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.completion,
        ModelCapability.analysis,
        ModelCapability.reasoning,
        ModelCapability.multimodal
      ],
      maxTokens: 128000,
      description:
          'Latest ChatGPT-4o with enhanced capabilities and large context',
      bestFor: [
        'Long conversations',
        'Document analysis',
        'Multimodal tasks',
        'Complex reasoning'
      ],
      limitations: ['Moderate cost'],
    ),
    'deepseek/deepseek-r1-0528:free': ModelProfile(
      id: 'deepseek/deepseek-r1-0528:free',
      name: 'DeepSeek R1 (Free)',
      provider: 'DeepSeek',
      tier: ModelTier.free,
      speed: ModelSpeed.medium,
      cost: ModelCost.free,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.reasoning,
        ModelCapability.analysis
      ],
      maxTokens: 8192,
      description: 'Free reasoning model with strong analytical capabilities',
      bestFor: ['Budget-conscious users', 'Reasoning tasks', 'Analysis'],
      limitations: ['Rate limits', 'Potential availability issues'],
    ),
    'anthropic/claude-3-haiku': ModelProfile(
      id: 'anthropic/claude-3-haiku',
      name: 'Claude 3 Haiku',
      provider: 'Anthropic',
      tier: ModelTier.standard,
      speed: ModelSpeed.fast,
      cost: ModelCost.low,
      capabilities: [ModelCapability.chat, ModelCapability.completion],
      maxTokens: 200000,
      description: 'Fast and lightweight Claude model with large context',
      bestFor: ['Long documents', 'Quick responses', 'Large context tasks'],
      limitations: ['Limited reasoning capabilities'],
    ),
    'anthropic/claude-3-sonnet': ModelProfile(
      id: 'anthropic/claude-3-sonnet',
      name: 'Claude 3 Sonnet',
      provider: 'Anthropic',
      tier: ModelTier.premium,
      speed: ModelSpeed.medium,
      cost: ModelCost.medium,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.completion,
        ModelCapability.analysis,
        ModelCapability.reasoning
      ],
      maxTokens: 200000,
      description: 'Balanced Claude model for most tasks with large context',
      bestFor: ['Balanced performance', 'Long conversations', 'Analysis'],
      limitations: ['Moderate cost'],
    ),
    'google/gemini-pro': ModelProfile(
      id: 'google/gemini-pro',
      name: 'Gemini Pro',
      provider: 'Google',
      tier: ModelTier.premium,
      speed: ModelSpeed.fast,
      cost: ModelCost.low,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.completion,
        ModelCapability.multimodal
      ],
      maxTokens: 32768,
      description: 'Google\'s advanced multimodal model',
      bestFor: ['Multimodal tasks', 'Cost-effective premium features'],
      limitations: ['Limited availability in some regions'],
    ),
  };

  /// Get model profile by ID
  static ModelProfile? getModelProfile(String modelId) {
    return _modelProfiles[modelId];
  }

  /// Get all available model profiles
  static List<ModelProfile> getAllModelProfiles() {
    return _modelProfiles.values.toList();
  }

  /// Recommend model based on use case
  static List<ModelProfile> recommendModels({
    required UseCase useCase,
    ModelCost? maxCost,
    ModelSpeed? minSpeed,
    bool requiresMultimodal = false,
    int? minTokens,
  }) {
    var candidates = _modelProfiles.values.where((model) {
      // Filter by cost
      if (maxCost != null && model.cost.index > maxCost.index) {
        return false;
      }

      // Filter by speed
      if (minSpeed != null && model.speed.index < minSpeed.index) {
        return false;
      }

      // Filter by multimodal requirement
      if (requiresMultimodal &&
          !model.capabilities.contains(ModelCapability.multimodal)) {
        return false;
      }

      // Filter by token requirement
      if (minTokens != null && model.maxTokens < minTokens) {
        return false;
      }

      // Filter by use case capabilities
      switch (useCase) {
        case UseCase.quickChat:
          return model.capabilities.contains(ModelCapability.chat);
        case UseCase.complexReasoning:
          return model.capabilities.contains(ModelCapability.reasoning);
        case UseCase.codeAnalysis:
          return model.capabilities.contains(ModelCapability.analysis);
        case UseCase.longConversation:
          return model.maxTokens >= 32000;
        case UseCase.multimodal:
          return model.capabilities.contains(ModelCapability.multimodal);
        case UseCase.budgetFriendly:
          return model.cost == ModelCost.free || model.cost == ModelCost.low;
      }
    }).toList();

    // Sort by suitability for use case
    candidates.sort((a, b) => _calculateSuitabilityScore(b, useCase)
        .compareTo(_calculateSuitabilityScore(a, useCase)));

    return candidates;
  }

  /// Calculate suitability score for a model and use case
  static int _calculateSuitabilityScore(ModelProfile model, UseCase useCase) {
    int score = 0;

    switch (useCase) {
      case UseCase.quickChat:
        score += model.speed.index * 3;
        score += (ModelCost.values.length - model.cost.index) * 2;
        break;
      case UseCase.complexReasoning:
        if (model.capabilities.contains(ModelCapability.reasoning)) score += 5;
        if (model.capabilities.contains(ModelCapability.analysis)) score += 3;
        score += model.tier.index * 2;
        break;
      case UseCase.codeAnalysis:
        if (model.capabilities.contains(ModelCapability.analysis)) score += 5;
        if (model.capabilities.contains(ModelCapability.reasoning)) score += 3;
        score += model.tier.index * 2;
        break;
      case UseCase.longConversation:
        score += (model.maxTokens / 10000).round();
        score += model.speed.index;
        break;
      case UseCase.multimodal:
        if (model.capabilities.contains(ModelCapability.multimodal)) {
          score += 10;
        }
        score += model.tier.index;
        break;
      case UseCase.budgetFriendly:
        score += (ModelCost.values.length - model.cost.index) * 5;
        if (model.cost == ModelCost.free) score += 10;
        break;
    }

    return score;
  }

  /// Get the best model for a specific use case
  static ModelProfile? getBestModelFor(UseCase useCase) {
    final recommendations = recommendModels(useCase: useCase);
    return recommendations.isNotEmpty ? recommendations.first : null;
  }

  /// Get models by provider
  static List<ModelProfile> getModelsByProvider(String provider) {
    return _modelProfiles.values
        .where(
            (model) => model.provider.toLowerCase() == provider.toLowerCase())
        .toList();
  }

  /// Get free models
  static List<ModelProfile> getFreeModels() {
    return _modelProfiles.values
        .where((model) => model.cost == ModelCost.free)
        .toList();
  }

  /// Get models with specific capability
  static List<ModelProfile> getModelsWithCapability(
      ModelCapability capability) {
    return _modelProfiles.values
        .where((model) => model.capabilities.contains(capability))
        .toList();
  }
}

/// Model profile containing detailed information about an AI model
class ModelProfile {
  final String id;
  final String name;
  final String provider;
  final ModelTier tier;
  final ModelSpeed speed;
  final ModelCost cost;
  final List<ModelCapability> capabilities;
  final int maxTokens;
  final String description;
  final List<String> bestFor;
  final List<String> limitations;

  const ModelProfile({
    required this.id,
    required this.name,
    required this.provider,
    required this.tier,
    required this.speed,
    required this.cost,
    required this.capabilities,
    required this.maxTokens,
    required this.description,
    required this.bestFor,
    required this.limitations,
  });

  /// Check if model has a specific capability
  bool hasCapability(ModelCapability capability) {
    return capabilities.contains(capability);
  }

  /// Get a user-friendly description of the model's strengths
  String get strengthsDescription {
    final strengths = <String>[];

    if (speed == ModelSpeed.fast) strengths.add('Fast responses');
    if (cost == ModelCost.free) strengths.add('Free to use');
    if (cost == ModelCost.low) strengths.add('Low cost');
    if (maxTokens >= 100000) strengths.add('Large context window');
    if (hasCapability(ModelCapability.multimodal)) {
      strengths.add('Multimodal support');
    }
    if (hasCapability(ModelCapability.reasoning)) {
      strengths.add('Strong reasoning');
    }

    return strengths.join(', ');
  }
}

/// Model performance tiers
enum ModelTier { free, standard, premium }

/// Model response speed categories
enum ModelSpeed { slow, medium, fast }

/// Model cost categories
enum ModelCost { free, low, medium, high }

/// Model capabilities
enum ModelCapability {
  chat,
  completion,
  analysis,
  reasoning,
  multimodal,
  coding,
}

/// Common use cases for model selection
enum UseCase {
  quickChat,
  complexReasoning,
  codeAnalysis,
  longConversation,
  multimodal,
  budgetFriendly,
}
