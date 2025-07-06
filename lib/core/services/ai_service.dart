import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/ai_message.dart';
import '../models/openrouter_models.dart';
import '../utils/environment_config.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._();

  AIService._();

  final String _baseUrl =
      dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
  final String _defaultModel =
      dotenv.env['DEFAULT_AI_MODEL'] ?? 'openai/gpt-3.5-turbo';
  final String _fallbackModel =
      dotenv.env['FALLBACK_AI_MODEL'] ?? 'openai/gpt-3.5-turbo';

  /// Send a chat completion request to OpenRouter
  Future<AIMessage> sendMessage({
    required List<AIMessage> messages,
    String? model,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        throw AIServiceException('OpenRouter API key not configured');
      }

      final selectedModel = model ?? _defaultModel;

      // Convert AIMessage list to OpenRouter format
      final openRouterMessages = messages
          .where((msg) => !msg.isLoading && msg.error == null)
          .map((msg) => OpenRouterMessage(
                role: msg.role,
                content: msg.content,
              ))
          .toList();

      final request = OpenRouterRequest(
        model: selectedModel,
        messages: openRouterMessages,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      final response = await _makeRequest(request);

      if (response.choices.isEmpty) {
        throw AIServiceException('No response choices received');
      }

      final choice = response.choices.first;
      return AIMessage.assistant(
        content: choice.message.content,
        id: response.id,
      );
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException('Failed to send message: ${e.toString()}');
    }
  }

  /// Make HTTP request to OpenRouter API
  Future<OpenRouterResponse> _makeRequest(OpenRouterRequest request) async {
    final uri = Uri.parse('$_baseUrl/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://whatsapp-microlearning-bot.app',
      'X-Title': 'WhatsApp MicroLearning Bot',
    };

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = response.body;
      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return OpenRouterResponse.fromJson(responseData);
      } else {
        // Handle error response
        if (responseData.containsKey('error')) {
          final errorResponse = OpenRouterErrorResponse.fromJson(responseData);
          throw AIServiceException(
            'API Error: ${errorResponse.error.message}',
            statusCode: response.statusCode,
          );
        } else {
          throw AIServiceException(
            'HTTP Error: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }
    } on SocketException {
      throw AIServiceException(
          'Network error: Please check your internet connection');
    } on HttpException {
      throw AIServiceException('HTTP error occurred');
    } on FormatException {
      throw AIServiceException('Invalid response format received');
    }
  }

  /// Get available models with their capabilities
  Future<List<Map<String, dynamic>>> getAvailableModels() async {
    // This would typically fetch from OpenRouter's models endpoint
    return [
      {
        'id': 'openai/gpt-3.5-turbo',
        'name': 'GPT-3.5 Turbo',
        'description': 'Fast and efficient for most tasks',
        'maxTokens': 4096,
        'costPer1kTokens': 0.002,
        'provider': 'OpenAI',
        'capabilities': ['chat', 'completion'],
      },
      {
        'id': 'openai/gpt-4',
        'name': 'GPT-4',
        'description': 'Most capable model for complex reasoning',
        'maxTokens': 8192,
        'costPer1kTokens': 0.03,
        'provider': 'OpenAI',
        'capabilities': ['chat', 'completion', 'analysis'],
      },
      {
        'id': 'openai/chatgpt-4o-latest',
        'name': 'ChatGPT-4o Latest',
        'description': 'Latest ChatGPT-4o model with enhanced capabilities',
        'maxTokens': 128000,
        'costPer1kTokens': 0.005,
        'provider': 'OpenAI',
        'capabilities': ['chat', 'completion', 'analysis', 'multimodal'],
      },
      {
        'id': 'deepseek/deepseek-r1-0528:free',
        'name': 'DeepSeek R1 (Free)',
        'description':
            'Free reasoning model with strong analytical capabilities',
        'maxTokens': 8192,
        'costPer1kTokens': 0.0,
        'provider': 'DeepSeek',
        'capabilities': ['chat', 'reasoning', 'analysis'],
      },
      {
        'id': 'anthropic/claude-3-haiku',
        'name': 'Claude 3 Haiku',
        'description': 'Fast and lightweight Claude model',
        'maxTokens': 200000,
        'costPer1kTokens': 0.00025,
        'provider': 'Anthropic',
        'capabilities': ['chat', 'completion'],
      },
      {
        'id': 'anthropic/claude-3-sonnet',
        'name': 'Claude 3 Sonnet',
        'description': 'Balanced Claude model for most tasks',
        'maxTokens': 200000,
        'costPer1kTokens': 0.003,
        'provider': 'Anthropic',
        'capabilities': ['chat', 'completion', 'analysis'],
      },
      {
        'id': 'google/gemini-pro',
        'name': 'Gemini Pro',
        'description': 'Google\'s advanced multimodal model',
        'maxTokens': 32768,
        'costPer1kTokens': 0.0005,
        'provider': 'Google',
        'capabilities': ['chat', 'completion', 'multimodal'],
      },
    ];
  }

  /// Get simple list of model IDs for backward compatibility
  Future<List<String>> getModelIds() async {
    final models = await getAvailableModels();
    return models.map((model) => model['id'] as String).toList();
  }

  /// Get current model
  Future<String> getCurrentModel() async {
    // TODO: Get from user preferences or return default
    return EnvironmentConfig.defaultAiModel;
  }

  /// Set current model
  Future<void> setModel(String modelId) async {
    // TODO: Save to user preferences
    // For now, we'll just validate the model exists
    final availableModels = await getModelIds();
    if (!availableModels.contains(modelId)) {
      throw AIServiceException('Model $modelId is not available');
    }

    // TODO: Implement actual model switching logic
    log('Model set to: $modelId');
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final testMessages = [
        AIMessage.system(content: 'You are a helpful assistant.'),
        AIMessage.user(content: 'Hello, this is a connection test.'),
      ];

      await sendMessage(
        messages: testMessages,
        maxTokens: 10,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current configuration
  Map<String, dynamic> getConfiguration() {
    return {
      'baseUrl': _baseUrl,
      'hasApiKey': _apiKey.isNotEmpty,
      'defaultModel': _defaultModel,
      'fallbackModel': _fallbackModel,
    };
  }
}

/// Custom exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final int? statusCode;

  const AIServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'AIServiceException: $message';
}
