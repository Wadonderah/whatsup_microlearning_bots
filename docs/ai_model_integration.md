# AI Model Integration Guide

This guide covers the comprehensive AI model integration in the WhatsApp MicroLearning Bot, including support for multiple AI providers and models through OpenRouter.

## Overview

The app supports multiple AI models through OpenRouter's unified API, giving users choice and flexibility in their learning experience. Models include:

- **OpenAI GPT Models**: GPT-3.5 Turbo, GPT-4, ChatGPT-4o Latest
- **DeepSeek Models**: DeepSeek R1 (Free reasoning model)
- **Anthropic Claude**: Claude 3 Haiku, Claude 3 Sonnet
- **Google Gemini**: Gemini Pro

## Architecture

### Core Components

#### AIService
Central service for AI interactions:
```dart
class AIService {
  // Send messages to AI models
  Future<String> sendMessage({
    required List<AIMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
  });
  
  // Get available models
  Future<List<Map<String, dynamic>>> getAvailableModels();
  
  // Model management
  Future<String> getCurrentModel();
  Future<void> setModel(String modelId);
}
```

#### ModelSelector
Intelligent model recommendation system:
```dart
class ModelSelector {
  // Get model recommendations based on use case
  static List<ModelProfile> recommendModels({
    required UseCase useCase,
    ModelCost? maxCost,
    ModelSpeed? minSpeed,
    bool requiresMultimodal = false,
  });
  
  // Get best model for specific use case
  static ModelProfile? getBestModelFor(UseCase useCase);
}
```

### Model Profiles

Each model has a comprehensive profile:

```dart
class ModelProfile {
  final String id;              // Model identifier
  final String name;            // Display name
  final String provider;        // Provider (OpenAI, Anthropic, etc.)
  final ModelTier tier;         // free, standard, premium
  final ModelSpeed speed;       // slow, medium, fast
  final ModelCost cost;         // free, low, medium, high
  final List<ModelCapability> capabilities;
  final int maxTokens;          // Context window size
  final String description;     // Model description
  final List<String> bestFor;   // Use case recommendations
  final List<String> limitations; // Known limitations
}
```

## Available Models

### OpenAI Models

#### GPT-3.5 Turbo
- **ID**: `openai/gpt-3.5-turbo`
- **Best For**: Quick responses, general chat, simple explanations
- **Max Tokens**: 4,096
- **Cost**: Low
- **Speed**: Fast

#### GPT-4
- **ID**: `openai/gpt-4`
- **Best For**: Complex problem solving, detailed analysis, code review
- **Max Tokens**: 8,192
- **Cost**: High
- **Speed**: Medium

#### ChatGPT-4o Latest ⭐ **Recommended for Learning**
- **ID**: `openai/chatgpt-4o-latest`
- **Best For**: Long conversations, document analysis, multimodal tasks
- **Max Tokens**: 128,000
- **Cost**: Medium
- **Speed**: Fast
- **Special Features**: Large context window, multimodal support

### DeepSeek Models

#### DeepSeek R1 (Free) 🆓
- **ID**: `deepseek/deepseek-r1-0528:free`
- **Best For**: Budget-conscious users, reasoning tasks, analysis
- **Max Tokens**: 8,192
- **Cost**: Free
- **Speed**: Medium
- **Note**: Rate limits may apply

### Anthropic Models

#### Claude 3 Haiku
- **ID**: `anthropic/claude-3-haiku`
- **Best For**: Long documents, quick responses, large context tasks
- **Max Tokens**: 200,000
- **Cost**: Low
- **Speed**: Fast

#### Claude 3 Sonnet
- **ID**: `anthropic/claude-3-sonnet`
- **Best For**: Balanced performance, long conversations, analysis
- **Max Tokens**: 200,000
- **Cost**: Medium
- **Speed**: Medium

### Google Models

#### Gemini Pro
- **ID**: `google/gemini-pro`
- **Best For**: Multimodal tasks, cost-effective premium features
- **Max Tokens**: 32,768
- **Cost**: Low
- **Speed**: Fast

## Configuration

### Environment Variables

```env
# AI Model Configuration
DEFAULT_AI_MODEL=openai/gpt-3.5-turbo
FALLBACK_AI_MODEL=openai/gpt-3.5-turbo

# Alternative models:
# DEFAULT_AI_MODEL=openai/chatgpt-4o-latest  # Latest ChatGPT-4o
# DEFAULT_AI_MODEL=deepseek/deepseek-r1-0528:free  # Free reasoning model
# DEFAULT_AI_MODEL=anthropic/claude-3-sonnet  # Balanced Claude model

# OpenRouter Configuration
OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
```

### Model Selection

Users can select models through the AI Model Settings screen:

```dart
// Navigate to model settings
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AIModelSettingsScreen(),
  ),
);
```

## Usage Examples

### Basic AI Interaction

```dart
final aiService = AIService.instance;

// Send a message with default model
final response = await aiService.sendMessage(
  messages: [
    AIMessage.user(content: 'Explain quantum physics'),
  ],
);
```

### Model-Specific Requests

```dart
// Use specific model for reasoning tasks
final response = await aiService.sendMessage(
  messages: [
    AIMessage.user(content: 'Solve this complex math problem'),
  ],
  model: 'deepseek/deepseek-r1-0528:free',
);
```

### Model Recommendations

```dart
// Get best model for specific use case
final bestModel = ModelSelector.getBestModelFor(UseCase.complexReasoning);

// Get budget-friendly options
final freeModels = ModelSelector.getFreeModels();

// Get models with specific capabilities
final multimodalModels = ModelSelector.getModelsWithCapability(
  ModelCapability.multimodal,
);
```

## Smart Model Selection

The app includes intelligent model recommendation based on:

### Use Cases
- **Quick Chat**: Fast, low-cost models
- **Complex Reasoning**: High-capability models with reasoning
- **Code Analysis**: Models with strong analytical capabilities
- **Long Conversation**: Models with large context windows
- **Multimodal**: Models supporting images and text
- **Budget Friendly**: Free or low-cost options

### Automatic Recommendations

```dart
// Get recommendations for learning tasks
final recommendations = ModelSelector.recommendModels(
  useCase: UseCase.complexReasoning,
  maxCost: ModelCost.medium,
  minSpeed: ModelSpeed.medium,
);
```

## User Interface

### Model Selection Screen

The AI Model Settings screen provides:

- **Quick Recommendations**: Pre-configured options for common use cases
- **Detailed Model List**: Complete information about each model
- **Cost and Speed Indicators**: Visual indicators for model characteristics
- **Capability Tags**: Clear indication of model features
- **Real-time Selection**: Immediate feedback on model choice

### Features

- **Visual Cost Indicators**: Color-coded cost levels
- **Speed Badges**: Performance indicators
- **Capability Chips**: Feature highlights
- **Best For Suggestions**: Use case recommendations
- **Limitation Warnings**: Transparent about model constraints

## OpenRouter Integration

### API Configuration

```dart
// OpenRouter-compatible request
final response = await http.post(
  Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://your-app.com',
    'X-Title': 'WhatsApp MicroLearning Bot',
  },
  body: jsonEncode({
    'model': selectedModel,
    'messages': messages,
    'max_tokens': maxTokens,
    'temperature': temperature,
  }),
);
```

### Error Handling

```dart
try {
  final response = await aiService.sendMessage(messages: messages);
  // Handle successful response
} on AIServiceException catch (e) {
  // Handle AI service specific errors
  print('AI Error: ${e.message}');
} catch (e) {
  // Handle general errors
  print('General Error: $e');
}
```

## Best Practices

### Model Selection Guidelines

1. **For Learning**: Use `openai/chatgpt-4o-latest` for comprehensive explanations
2. **For Quick Questions**: Use `openai/gpt-3.5-turbo` for fast responses
3. **For Budget Users**: Use `deepseek/deepseek-r1-0528:free` for free access
4. **For Long Documents**: Use Claude models with large context windows
5. **For Reasoning Tasks**: Use models with reasoning capabilities

### Performance Optimization

1. **Cache Model Profiles**: Load model information once and cache
2. **Smart Fallbacks**: Implement fallback models for reliability
3. **Rate Limiting**: Respect API rate limits and implement backoff
4. **Context Management**: Optimize token usage for cost efficiency

### User Experience

1. **Clear Recommendations**: Guide users to appropriate models
2. **Transparent Costs**: Show cost implications clearly
3. **Performance Indicators**: Display speed and capability information
4. **Easy Switching**: Allow quick model changes

## Monitoring and Analytics

### Usage Tracking

Track model usage for optimization:
- Model selection frequency
- User satisfaction by model
- Performance metrics
- Cost analysis

### Error Monitoring

Monitor for:
- API failures by model
- Rate limit hits
- Model availability issues
- User experience problems

## Future Enhancements

### Planned Features

1. **Dynamic Model Loading**: Fetch available models from OpenRouter API
2. **Usage Analytics**: Track model performance and user preferences
3. **Smart Auto-Selection**: Automatically choose best model for context
4. **Cost Tracking**: Monitor and display usage costs
5. **Custom Model Profiles**: Allow users to create custom configurations

### Integration Opportunities

1. **Learning Path Optimization**: Use different models for different learning stages
2. **Adaptive Difficulty**: Adjust model complexity based on user level
3. **Multimodal Learning**: Leverage image-capable models for visual learning
4. **Collaborative Learning**: Use multiple models for different perspectives

This comprehensive AI model integration provides users with flexibility, choice, and optimal learning experiences while maintaining cost efficiency and performance.
