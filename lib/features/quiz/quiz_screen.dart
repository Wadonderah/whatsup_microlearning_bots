import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/learning_content_models.dart';
import '../../core/services/microlearning_service.dart';
import '../auth/providers/auth_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<LearningQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _showAnswer = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  String? _userAnswer;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() => _isLoading = true);
      
      final questions = await MicrolearningService.instance
          .getRandomQuestions(widget.categoryId, limit: 5);
      
      setState(() {
        _questions = questions;
        _totalQuestions = questions.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  void _showAnswerAndExplanation() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showAnswer = false;
        _userAnswer = null;
        _isAnswerCorrect = false;
      });
    } else {
      _showQuizResults();
    }
  }

  void _submitAnswer(String answer) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer.toLowerCase().trim() == 
        currentQuestion.answer.toLowerCase().trim();
    
    setState(() {
      _userAnswer = answer;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    _showAnswerAndExplanation();
    _updateUserProgress(isCorrect);
  }

  Future<void> _updateUserProgress(bool isCorrect) async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    final userId = authState.user!.uid;
    final currentQuestion = _questions[_currentQuestionIndex];
    
    final progress = QuestionProgress(
      id: '${userId}_${currentQuestion.id}',
      userId: userId,
      questionId: currentQuestion.id,
      categoryId: widget.categoryId,
      isCompleted: true,
      isCorrect: isCorrect,
      attemptCount: 1,
      lastAttemptDate: DateTime.now(),
      completedDate: DateTime.now(),
      userAnswer: _userAnswer,
      timeSpentSeconds: 30, // Approximate time
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await MicrolearningService.instance.updateQuestionProgress(progress);
  }

  void _showQuizResults() {
    final percentage = (_correctAnswers / _totalQuestions) * 100;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              percentage >= 70 ? Icons.celebration : Icons.thumb_up,
              size: 64,
              color: percentage >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_correctAnswers/$_totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70 
                  ? 'Great job! You\'re mastering ${widget.categoryName}!'
                  : 'Good effort! Keep practicing to improve your score.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Back to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartQuiz();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _showAnswer = false;
      _userAnswer = null;
      _isAnswerCorrect = false;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.categoryName} Quiz'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.categoryName} Quiz'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No questions available for this category.'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Quiz'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blue.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question counter
            Text(
              'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Question card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.question,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    
                    if (!_showAnswer) ...[
                      // Answer input
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Type your answer here...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSubmitted: _submitAnswer,
                        onChanged: (value) {
                          setState(() {
                            _userAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _userAnswer?.isNotEmpty == true 
                            ? () => _submitAnswer(_userAnswer!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Submit Answer'),
                      ),
                    ] else ...[
                      // Show answer and feedback
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isAnswerCorrect ? Colors.green.shade50 : Colors.red.shade50,
                          border: Border.all(
                            color: _isAnswerCorrect ? Colors.green : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                                  color: _isAnswerCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isAnswerCorrect ? 'Correct!' : 'Incorrect',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isAnswerCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Correct Answer:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(currentQuestion.answer),
                            if (!_isAnswerCorrect && _userAnswer != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Your Answer: $_userAnswer',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1 
                              ? 'Next Question' 
                              : 'Finish Quiz'
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Score display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_correctAnswers',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Correct'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${_currentQuestionIndex + 1 - _correctAnswers}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Text('Incorrect'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${((_correctAnswers / (_currentQuestionIndex + 1)) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('Accuracy'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
