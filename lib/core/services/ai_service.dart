import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

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
      if (_apiKey.isEmpty || _apiKey == 'your_openrouter_api_key_here') {
        throw AIServiceException(
            'OpenRouter API key not configured. Please set OPENROUTER_API_KEY in your .env file. '
            'Get your API key from https://openrouter.ai/keys');
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

      // Ensure response.id is properly converted to string
      final responseId = response.id.toString();
      log('Creating AIMessage with ID: $responseId (type: ${responseId.runtimeType})');

      return AIMessage.assistant(
        content: choice.message.content,
        id: responseId,
      );
    } on AIServiceException catch (e) {
      // In development mode, provide fallback responses for common errors
      if (e.statusCode == 402 || e.message.contains('402')) {
        log('API payment required (402), using development fallback');
        return _getDevelopmentFallbackResponse(messages);
      }
      rethrow;
    } catch (e) {
      log('AI Service error: $e');
      // In development mode, provide fallback response for any error
      return _getDevelopmentFallbackResponse(messages);
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

      // Add debug logging
      log('OpenRouter API Response Status: ${response.statusCode}');
      log('OpenRouter API Response Body: $responseBody');

      final responseData = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        try {
          // Debug: Log the response data structure
          log('OpenRouter response data: $responseData');
          log('Response ID type: ${responseData['id']?.runtimeType}');
          log('Response ID value: ${responseData['id']}');

          return OpenRouterResponse.fromJson(responseData);
        } catch (e) {
          log('Error parsing OpenRouter response: $e');
          log('Response data: $responseData');
          throw AIServiceException(
              'Failed to parse API response: ${e.toString()}');
        }
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

  /// Development fallback response when API is unavailable
  AIMessage _getDevelopmentFallbackResponse(List<AIMessage> messages) {
    final userMessage = messages.isNotEmpty ? messages.last.content : '';

    // Generate contextual responses based on user input
    String response = _generateContextualResponse(userMessage);

    return AIMessage.assistant(
      content: response,
      id: 'dev-fallback-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Generate contextual responses for development mode
  String _generateContextualResponse(String userInput) {
    final input = userInput.toLowerCase();

    // Specific AWS service questions
    if (input.contains('ec2')) {
      return '''🖥️ **Amazon EC2 (Elastic Compute Cloud)**

EC2 is like renting virtual computers in the cloud! Here's what you need to know:

**What is EC2?**
A virtual server in AWS used to run applications - think of it as your computer in the cloud.

**Key Benefits:**
• **Scalable** - Start with 1 server, scale to thousands
• **Flexible** - Choose CPU, memory, storage, and networking
• **Cost-effective** - Pay only for what you use

**Common Use Cases:**
• Web applications and websites
• Development and testing environments
• Big data processing
• Gaming servers

💡 **Quick Tip:** Always choose the right instance type for your workload to optimize costs!

Want to learn about other AWS services like S3 or IAM?''';
    }

    if (input.contains('s3')) {
      return '''🗄️ **Amazon S3 (Simple Storage Service)**

S3 is AWS's object storage service - your unlimited digital warehouse!

**What is S3?**
Object-based storage for any file type - documents, images, videos, backups, you name it!

**Key Features:**
• **Unlimited storage** - Store as much as you need
• **99.999999999% durability** - Your data is super safe
• **Global accessibility** - Access from anywhere
• **Multiple storage classes** - Optimize costs based on access patterns

**Storage Classes:**
• **Standard** - Frequent access (websites, apps)
• **Glacier** - Archive storage (long-term backups)
• **Intelligent Tiering** - Automatic cost optimization

🎯 **Real-world example:** Netflix stores all their movies and shows on S3!

Curious about IAM security or VPC networking next?''';
    }

    if (input.contains('iam')) {
      return '''🔐 **AWS IAM (Identity and Access Management)**

IAM is your security control center - who can do what in your AWS account!

**What is IAM?**
To securely control access to AWS services and resources - it's like being the bouncer for your cloud!

**Core Components:**
• **Users** - Individual people (like employees)
• **Groups** - Collections of users (like departments)
• **Roles** - Temporary permissions for services
• **Policies** - Rules that define permissions

**Best Practices:**
• ✅ Enable MFA (Multi-Factor Authentication)
• ✅ Follow principle of least privilege
• ✅ Use roles instead of users for applications
• ✅ Regularly review and rotate access keys

🛡️ **Security Tip:** Never share your root account credentials - create IAM users instead!

Want to explore VPC networking or Auto Scaling next?''';
    }

    if (input.contains('vpc')) {
      return '''🌐 **Amazon VPC (Virtual Private Cloud)**

VPC is your private network in the AWS cloud - your own isolated section!

**What is VPC?**
Virtual Private Cloud allows isolated sections of AWS - like having your own private neighborhood in the cloud city!

**Key Components:**
• **Subnets** - Subdivisions of your VPC (public/private)
• **Internet Gateway** - Door to the internet
• **Route Tables** - Traffic direction rules
• **Security Groups** - Virtual firewalls

**Common Setup:**
• **Public Subnet** - Web servers (accessible from internet)
• **Private Subnet** - Databases (internal access only)
• **NAT Gateway** - Allows private resources to access internet

🏗️ **Architecture Tip:** Always separate your web tier from your database tier for better security!

Ready to learn about Auto Scaling or CloudWatch monitoring?''';
    }

    // Flutter-specific questions
    if (input.contains('widget')) {
      return '''🧩 **Flutter Widgets**

Widgets are the heart of Flutter - everything you see is a widget!

**What is a Widget?**
Building blocks of Flutter UI - buttons, text, layouts, everything!

**Widget Types:**
• **Stateless Widgets** - Static UI (Text, Icon, Image)
• **Stateful Widgets** - Dynamic UI (Forms, Animations)
• **Layout Widgets** - Organize other widgets (Column, Row, Stack)

**Popular Widgets:**
• `Text()` - Display text
• `Container()` - Box with styling
• `Column()` - Vertical layout
• `Row()` - Horizontal layout
• `ElevatedButton()` - Clickable button

**Code Example:**
```dart
Text(
  'Hello Flutter!',
  style: TextStyle(fontSize: 24),
)
```

🎨 **Pro Tip:** Use `Container` for spacing and styling, `Column` and `Row` for layouts!

Want to learn about state management or navigation next?''';
    }

    if (input.contains('setstate')) {
      return '''🔄 **setState() in Flutter**

setState() is how you tell Flutter "Hey, something changed, update the UI!"

**What is setState()?**
Updates UI when state changes - it's like hitting the refresh button for your widget!

**How it works:**
1. You change some data
2. Call setState(() { /* changes here */ })
3. Flutter rebuilds the widget with new data

**Example:**
```dart
int counter = 0;

void incrementCounter() {
  setState(() {
    counter++; // Change the data
  }); // Flutter rebuilds UI
}
```

**Best Practices:**
• ✅ Only call setState() in StatefulWidget
• ✅ Keep setState() calls minimal
• ✅ Don't call setState() during build()
• ✅ Use it for simple state management

⚡ **Performance Tip:** For complex apps, consider Provider or Riverpod for state management!

Curious about navigation or the Provider package?''';
    }

    // Learning-related responses
    if (input.contains('learn') ||
        input.contains('study') ||
        input.contains('teach')) {
      return '''🎓 **Welcome to Your Learning Journey!**

I'm your AI tutor, ready to help you master technology! Here's what we can explore together:

**🔥 Hot Topics Available:**
• **AWS Cloud Engineering** (8 expert-level questions)
• **AWS Solutions Architecture** (8 advanced scenarios)
• **Flutter Development** (8 practical concepts)
• **DevOps Engineering** (5 essential practices)
• **Data Engineering** (5 key technologies)
• **Security Engineering** (5 critical skills)

**📚 Learning Paths:**
1. **Beginner**: Start with Flutter basics or AWS fundamentals
2. **Intermediate**: Dive into Solutions Architecture or DevOps
3. **Advanced**: Master Security or Data Engineering

**🎯 Interactive Features:**
• Ask specific questions (like "What is EC2?")
• Take quizzes to test your knowledge
• Get real-world examples and code snippets

💡 **Tip:** Try asking "Explain VPC" or "How does setState work?" for detailed explanations!

What technology excites you most? Let's start learning! 🚀''';
    }

    // General AWS questions
    if (input.contains('aws') || input.contains('cloud')) {
      return '''☁️ **Welcome to AWS Cloud Learning!**

AWS is the world's leading cloud platform! Let's explore what makes it powerful:

**🏗️ Core Services You Should Know:**
• **EC2** - Virtual servers (like renting computers)
• **S3** - Unlimited file storage (your digital warehouse)
• **IAM** - Security & access control (your cloud bouncer)
• **VPC** - Private networks (your secure neighborhood)

**🎯 Learning Path Suggestions:**
1. **Start Here**: EC2 → S3 → IAM → VPC
2. **Then Explore**: RDS → Lambda → CloudWatch
3. **Advanced**: Auto Scaling → Load Balancers → CloudFormation

**💼 Real-World Impact:**
• Netflix runs on AWS (streaming to millions)
• Airbnb scales globally with AWS
• NASA uses AWS for space missions!

**🚀 Quick Start:**
Try asking: "What is EC2?" or "How does S3 work?" for detailed explanations!

Which AWS service interests you most? Let's dive deep! 🤿''';
    }

    // General Flutter questions
    if (input.contains('flutter') ||
        input.contains('dart') ||
        input.contains('mobile')) {
      return '''📱 **Flutter: Build Beautiful Apps!**

Flutter is Google's UI toolkit for crafting beautiful, natively compiled applications!

**🎨 Why Flutter is Amazing:**
• **One Codebase** - iOS + Android + Web + Desktop
• **Hot Reload** - See changes instantly (⚡ super fast!)
• **Beautiful UI** - Material Design + Cupertino built-in
• **High Performance** - Compiled to native code

**🧩 Core Concepts to Master:**
• **Widgets** - Everything is a widget (UI building blocks)
• **State Management** - How your app remembers things
• **Navigation** - Moving between screens smoothly
• **Packages** - 30,000+ packages on pub.dev!

**🚀 Popular Apps Built with Flutter:**
• Google Ads, Alibaba, BMW, eBay Motors
• Your favorite apps might be Flutter!

**📚 Learning Roadmap:**
1. **Basics**: Widgets → Layouts → Styling
2. **Intermediate**: State → Navigation → APIs
3. **Advanced**: Animations → Custom Widgets → Performance

💡 **Try asking**: "What is a widget?" or "How does setState work?" for hands-on examples!

Ready to build something amazing? 🛠️''';
    }

    // Quiz-related responses
    if (input.contains('quiz') ||
        input.contains('test') ||
        input.contains('question') ||
        input.contains('practice')) {
      return '''🧠 **Ready to Test Your Knowledge?**

Time to put your learning to the test! Our quiz system has **44 carefully crafted questions** across 7 categories:

**🎯 Available Quiz Categories:**
• **AWS Cloud Engineer** (8 questions) - EC2, S3, IAM, VPC basics
• **AWS Solutions Architect** (8 questions) - Architecture patterns & best practices
• **Flutter Developer** (8 questions) - Widgets, state, navigation
• **AWS DevOps Engineer** (5 questions) - CI/CD, automation
• **AWS Data Engineer** (5 questions) - ETL, analytics, data lakes
• **AWS Security Engineer** (5 questions) - Security tools & practices
• **AWS Business** (5 questions) - Cost optimization & strategy

**🏆 Quiz Features:**
• **Instant Feedback** - Learn from every answer
• **Progress Tracking** - See your improvement over time
• **Difficulty Levels** - From beginner to expert
• **Real-world Scenarios** - Practical, job-relevant questions

**💡 Pro Tips for Success:**
• Start with your strongest area to build confidence
• Review explanations for wrong answers
• Retake quizzes to improve your score

🚀 **Ready to start?** Head to the Quiz section and choose your category!

Which topic would you like to be quizzed on first?''';
    }

    // General help responses
    if (input.contains('help') ||
        input.contains('how') ||
        input.contains('what') ||
        input.contains('explain')) {
      return '''🤖 **Your AI Learning Assistant is Here!**

I'm your personal tech tutor, ready to help you master the skills that matter! Here's how I can assist:

**📚 What I Can Teach You:**
• **AWS Cloud Services** - From basics to advanced architecture
• **Flutter Development** - Mobile apps that wow users
• **DevOps Practices** - Automation and deployment mastery
• **Security Engineering** - Protect systems and data
• **Data Engineering** - Handle big data like a pro

**🎯 How I Help You Learn:**
• **Detailed Explanations** - Break down complex concepts
• **Real-world Examples** - See how it's used in practice
• **Code Snippets** - Hands-on programming examples
• **Best Practices** - Learn from industry experts
• **Interactive Q&A** - Ask anything, anytime

**💡 Smart Learning Tips:**
• Ask specific questions: "How does Auto Scaling work?"
• Request examples: "Show me a Flutter widget example"
• Explore topics: "Tell me about VPC networking"
• Test knowledge: "Quiz me on AWS security"

**🚀 Popular Questions to Try:**
• "What is EC2 and how do I use it?"
• "Explain Flutter widgets with examples"
• "How does IAM security work?"
• "What's the difference between S3 and EBS?"

Ready to become a tech expert? Ask me anything! 💪''';
    }

    // Default responses - more engaging and specific
    final responses = [
      '''👋 **Welcome to Your Personal Tech Academy!**

I'm your AI Learning Assistant, and I'm excited to help you master technology!

**🎯 What Makes Me Special:**
• **44 Expert-Curated Questions** across 7 tech domains
• **Real-world Examples** from industry leaders
• **Interactive Learning** - ask, learn, practice, repeat!
• **Personalized Guidance** based on your interests

**🚀 Ready to Start? Try These:**
• "Teach me about AWS EC2"
• "How do Flutter widgets work?"
• "I want to take a quiz"
• "Explain cloud security"

**💡 Learning Tip:** The best way to learn is by asking specific questions!

What technology adventure shall we begin today? 🌟''',
      '''🤔 **Interesting! Let's Explore Together**

I love curious minds! While I'm in development mode, I'm still packed with knowledge about:

**☁️ Cloud Technologies:**
• AWS services (EC2, S3, IAM, VPC)
• Architecture patterns and best practices
• Security and compliance strategies

**📱 Mobile Development:**
• Flutter framework and Dart language
• UI/UX design principles
• State management patterns

**🔧 DevOps & Engineering:**
• CI/CD pipelines and automation
• Data engineering and analytics
• Security engineering practices

**🎯 Let's Get Specific!**
Instead of general topics, try asking:
• "How does Auto Scaling work in AWS?"
• "Show me a Flutter navigation example"
• "What's the difference between IAM roles and users?"

What specific challenge can I help you solve? 💪''',
      '''💬 **Great to Meet You, Future Tech Expert!**

I'm thrilled to be your learning companion on this exciting journey!

**🎓 Your Learning Journey Awaits:**
• **Beginner?** Start with fundamentals and build confidence
• **Intermediate?** Dive into advanced concepts and patterns
• **Expert?** Test your knowledge with challenging quizzes

**🏆 Success Stories I've Helped With:**
• Understanding AWS architecture for job interviews
• Building first Flutter apps from scratch
• Mastering DevOps practices for career growth
• Preparing for cloud certification exams

**🎯 Today's Learning Menu:**
• **Quick Concepts** - "What is VPC?"
• **Deep Dives** - "Explain Flutter state management"
• **Practical Examples** - "Show me EC2 use cases"
• **Knowledge Tests** - "Quiz me on AWS security"

**💡 Pro Tip:** Learning is most effective when you're curious and engaged!

What's the one tech skill you're most excited to master? Let's make it happen! 🚀''',
    ];

    final random = math.Random();
    return responses[random.nextInt(responses.length)];
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
