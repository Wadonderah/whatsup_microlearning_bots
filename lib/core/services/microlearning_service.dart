import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../config/development_config.dart';
import '../models/learning_content_models.dart';

/// Service to manage microlearning content based on your Q&A dataset
class MicrolearningService {
  static final MicrolearningService _instance = MicrolearningService._internal();
  static MicrolearningService get instance => _instance;
  MicrolearningService._internal();

  final _uuid = const Uuid();
  final _random = Random();

  // In-memory storage for development mode
  final List<LearningContentCategory> _categories = [];
  final List<LearningQuestion> _questions = [];
  final Map<String, List<QuestionProgress>> _userProgress = {};

  /// Initialize the service with your microlearning dataset
  Future<void> initialize() async {
    if (DevelopmentConfig.isDevelopmentMode) {
      await _loadMicrolearningDataset();
      DevelopmentConfig.devLog('Microlearning service initialized with Q&A dataset');
    } else {
      // TODO: Load from Firebase in production
      DevelopmentConfig.devLog('Microlearning service initialized for production');
    }
  }

  /// Load your complete microlearning dataset
  Future<void> _loadMicrolearningDataset() async {
    // Clear existing data
    _categories.clear();
    _questions.clear();

    final now = DateTime.now();

    // Create categories based on your dataset
    final categories = [
      LearningContentCategory(
        id: 'aws-cloud-engineer',
        name: 'AWS Cloud Engineer',
        description: 'Essential AWS services and cloud engineering concepts',
        iconName: 'cloud',
        colorCode: '#FF9800',
        questionCount: 8,
        difficulty: DifficultyLevel.intermediate,
        tags: ['aws', 'cloud', 'engineering'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'aws-solutions-architect',
        name: 'AWS Solutions Architect',
        description: 'Architecture patterns and best practices for AWS',
        iconName: 'architecture',
        colorCode: '#2196F3',
        questionCount: 8,
        difficulty: DifficultyLevel.advanced,
        tags: ['aws', 'architecture', 'solutions'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'flutter-developer',
        name: 'Flutter Developer',
        description: 'Flutter framework and mobile app development',
        iconName: 'phone_android',
        colorCode: '#4CAF50',
        questionCount: 8,
        difficulty: DifficultyLevel.beginner,
        tags: ['flutter', 'mobile', 'development'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'aws-devops-engineer',
        name: 'AWS DevOps Engineer',
        description: 'CI/CD pipelines and DevOps practices on AWS',
        iconName: 'settings',
        colorCode: '#9C27B0',
        questionCount: 5,
        difficulty: DifficultyLevel.intermediate,
        tags: ['aws', 'devops', 'cicd'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'aws-data-engineer',
        name: 'AWS Data Engineer',
        description: 'Data processing and analytics on AWS',
        iconName: 'analytics',
        colorCode: '#607D8B',
        questionCount: 5,
        difficulty: DifficultyLevel.advanced,
        tags: ['aws', 'data', 'analytics'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'aws-security-engineer',
        name: 'AWS Security Engineer',
        description: 'Security best practices and tools on AWS',
        iconName: 'security',
        colorCode: '#F44336',
        questionCount: 5,
        difficulty: DifficultyLevel.advanced,
        tags: ['aws', 'security', 'compliance'],
        createdAt: now,
        updatedAt: now,
      ),
      LearningContentCategory(
        id: 'aws-business',
        name: 'AWS Business',
        description: 'Business aspects and cost optimization on AWS',
        iconName: 'business',
        colorCode: '#795548',
        questionCount: 5,
        difficulty: DifficultyLevel.beginner,
        tags: ['aws', 'business', 'cost'],
        createdAt: now,
        updatedAt: now,
      ),
    ];

    _categories.addAll(categories);

    // Create questions based on your complete dataset
    final questions = [
      // AWS Cloud Engineer (8 questions)
      _createQuestion('aws-cloud-engineer', 'What is EC2?', 'A virtual server in AWS used to run applications.', 0),
      _createQuestion('aws-cloud-engineer', 'What\'s the purpose of IAM?', 'To securely control access to AWS services and resources.', 1),
      _createQuestion('aws-cloud-engineer', 'What does S3 stand for?', 'Simple Storage Service, object-based storage for any file type.', 2),
      _createQuestion('aws-cloud-engineer', 'What is Auto Scaling?', 'Automatically adjusts the number of EC2 instances.', 3),
      _createQuestion('aws-cloud-engineer', 'What is a VPC?', 'Virtual Private Cloud, allows isolated sections of AWS.', 4),
      _createQuestion('aws-cloud-engineer', 'Difference between EBS and EFS?', 'EBS is block storage, EFS is shared file storage.', 5),
      _createQuestion('aws-cloud-engineer', 'How does CloudWatch help?', 'Monitors AWS services and resources with logs/metrics.', 6),
      _createQuestion('aws-cloud-engineer', 'What is CloudFormation?', 'IaC tool to automate infrastructure setup.', 7),

      // AWS Solutions Architect (8 questions)
      _createQuestion('aws-solutions-architect', 'What is the Well-Architected Framework?', 'A set of best practices for designing cloud solutions.', 0),
      _createQuestion('aws-solutions-architect', 'What is fault tolerance?', 'System\'s ability to operate through component failures.', 1),
      _createQuestion('aws-solutions-architect', 'Difference between S3 Standard and Glacier?', 'Standard is for frequent access, Glacier is for archive.', 2),
      _createQuestion('aws-solutions-architect', 'What is Multi-AZ RDS?', 'RDS instance replicated across multiple Availability Zones.', 3),
      _createQuestion('aws-solutions-architect', 'How does Load Balancer work?', 'Distributes traffic across multiple instances.', 4),
      _createQuestion('aws-solutions-architect', 'What is the Shared Responsibility Model?', 'AWS secures infrastructure, customer secures data.', 5),
      _createQuestion('aws-solutions-architect', 'What is AWS Snowball?', 'Physical device to transfer large datasets to AWS.', 6),
      _createQuestion('aws-solutions-architect', 'What tool estimates AWS cost?', 'AWS Pricing Calculator.', 7),

      // Flutter Developer (8 questions)
      _createQuestion('flutter-developer', 'What is a Widget?', 'Building block of Flutter UI.', 0),
      _createQuestion('flutter-developer', 'Difference between Stateless and Stateful Widget?', 'Stateless = no state, Stateful = dynamic UI.', 1),
      _createQuestion('flutter-developer', 'What is setState()?', 'Updates UI when state changes.', 2),
      _createQuestion('flutter-developer', 'Purpose of Provider package?', 'Manages and shares app state.', 3),
      _createQuestion('flutter-developer', 'How to navigate to a new screen?', 'Use Navigator.push(context, route).', 4),
      _createQuestion('flutter-developer', 'What\'s the use of SharedPreferences?', 'Store small local data like user settings.', 5),
      _createQuestion('flutter-developer', 'Best practice for theming?', 'Use ThemeData and define light/dark themes.', 6),
      _createQuestion('flutter-developer', 'How to handle REST API?', 'Use http package for network calls.', 7),

      // AWS DevOps Engineer (5 questions)
      _createQuestion('aws-devops-engineer', 'What is CI/CD?', 'Continuous Integration and Continuous Deployment pipelines.', 0),
      _createQuestion('aws-devops-engineer', 'What does CodePipeline do?', 'Automates software release process.', 1),
      _createQuestion('aws-devops-engineer', 'What is CodeBuild?', 'Builds and tests code in the cloud.', 2),
      _createQuestion('aws-devops-engineer', 'Use of CloudFormation?', 'Defines and provisions infrastructure as code.', 3),
      _createQuestion('aws-devops-engineer', 'What is Elastic Beanstalk?', 'Platform as a Service to deploy and manage applications.', 4),

      // AWS Data Engineer (5 questions)
      _createQuestion('aws-data-engineer', 'What is AWS Glue?', 'Serverless ETL service for data transformation.', 0),
      _createQuestion('aws-data-engineer', 'Purpose of Redshift?', 'Fast, scalable data warehouse.', 1),
      _createQuestion('aws-data-engineer', 'What is Kinesis used for?', 'Real-time data streaming.', 2),
      _createQuestion('aws-data-engineer', 'What is Athena?', 'Query service for S3 using SQL.', 3),
      _createQuestion('aws-data-engineer', 'What is Lake Formation?', 'Simplifies building a secure data lake.', 4),

      // AWS Security Engineer (5 questions)
      _createQuestion('aws-security-engineer', 'What is KMS?', 'Key Management Service to create and control encryption keys.', 0),
      _createQuestion('aws-security-engineer', 'What are Security Groups?', 'Virtual firewalls for EC2 instances.', 1),
      _createQuestion('aws-security-engineer', 'Difference between KMS and Secrets Manager?', 'KMS = key management, Secrets Manager = manage credentials.', 2),
      _createQuestion('aws-security-engineer', 'What is Inspector?', 'Automated security assessment service.', 3),
      _createQuestion('aws-security-engineer', 'Use of GuardDuty?', 'Threat detection service using machine learning.', 4),

      // AWS Business (5 questions)
      _createQuestion('aws-business', 'What is TCO Calculator?', 'Tool to estimate Total Cost of Ownership for AWS.', 0),
      _createQuestion('aws-business', 'AWS pricing model types?', 'On-Demand, Reserved, and Spot Instances.', 1),
      _createQuestion('aws-business', 'What is Cost Explorer?', 'Tool to visualize usage and costs.', 2),
      _createQuestion('aws-business', 'What does the Shared Responsibility Model mean for business?', 'AWS handles infra, business handles data compliance.', 3),
      _createQuestion('aws-business', 'What are the business benefits of AWS?', 'Scalability, agility, global reach, cost efficiency.', 4),
    ];

    _questions.addAll(questions);
  }

  /// Helper method to create a question
  LearningQuestion _createQuestion(String categoryId, String question, String answer, int orderIndex) {
    final now = DateTime.now();
    return LearningQuestion(
      id: _uuid.v4(),
      categoryId: categoryId,
      question: question,
      answer: answer,
      difficulty: DifficultyLevel.beginner,
      tags: [],
      relatedTopics: [],
      orderIndex: orderIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get all categories
  Future<List<LearningContentCategory>> getCategories() async {
    return List.from(_categories);
  }

  /// Get category by ID
  Future<LearningContentCategory?> getCategory(String categoryId) async {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get questions for a category
  Future<List<LearningQuestion>> getQuestionsByCategory(String categoryId) async {
    return _questions.where((q) => q.categoryId == categoryId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get random questions for a quiz
  Future<List<LearningQuestion>> getRandomQuestions(String categoryId, {int limit = 5}) async {
    final categoryQuestions = await getQuestionsByCategory(categoryId);
    if (categoryQuestions.length <= limit) {
      return categoryQuestions;
    }
    
    final shuffled = List<LearningQuestion>.from(categoryQuestions)..shuffle(_random);
    return shuffled.take(limit).toList();
  }

  /// Get a single random question from a category
  Future<LearningQuestion?> getRandomQuestion(String categoryId) async {
    final questions = await getRandomQuestions(categoryId, limit: 1);
    return questions.isNotEmpty ? questions.first : null;
  }

  /// Get user progress for a category
  Future<List<QuestionProgress>> getUserProgress(String userId, String categoryId) async {
    final userKey = '${userId}_$categoryId';
    return _userProgress[userKey] ?? [];
  }

  /// Update user progress for a question
  Future<void> updateQuestionProgress(QuestionProgress progress) async {
    final userKey = '${progress.userId}_${progress.categoryId}';
    final progressList = _userProgress[userKey] ?? [];
    
    final existingIndex = progressList.indexWhere((p) => p.questionId == progress.questionId);
    if (existingIndex >= 0) {
      progressList[existingIndex] = progress;
    } else {
      progressList.add(progress);
    }
    
    _userProgress[userKey] = progressList;
  }

  /// Get learning statistics for a user
  Future<Map<String, dynamic>> getLearningStats(String userId) async {
    int totalQuestions = _questions.length;
    int completedQuestions = 0;
    int correctAnswers = 0;
    
    for (final progressList in _userProgress.values) {
      for (final progress in progressList) {
        if (progress.userId == userId && progress.isCompleted) {
          completedQuestions++;
          if (progress.isCorrect) {
            correctAnswers++;
          }
        }
      }
    }
    
    return {
      'totalQuestions': totalQuestions,
      'completedQuestions': completedQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': completedQuestions > 0 ? (correctAnswers / completedQuestions) * 100 : 0.0,
      'completionRate': totalQuestions > 0 ? (completedQuestions / totalQuestions) * 100 : 0.0,
      'categories': _categories.length,
    };
  }

  /// Get next question for a user in a category (for progressive learning)
  Future<LearningQuestion?> getNextQuestion(String userId, String categoryId) async {
    final categoryQuestions = await getQuestionsByCategory(categoryId);
    final userProgress = await getUserProgress(userId, categoryId);
    
    // Find the first question that hasn't been completed
    for (final question in categoryQuestions) {
      final progress = userProgress.firstWhere(
        (p) => p.questionId == question.id,
        orElse: () => QuestionProgress(
          id: '',
          userId: userId,
          questionId: question.id,
          categoryId: categoryId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (!progress.isCompleted) {
        return question;
      }
    }
    
    return null; // All questions completed
  }
}
