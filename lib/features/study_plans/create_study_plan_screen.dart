import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/study_plan.dart';
import '../../core/services/study_plan_service.dart';
import '../auth/providers/auth_provider.dart';

class CreateStudyPlanScreen extends ConsumerStatefulWidget {
  const CreateStudyPlanScreen({super.key});

  @override
  ConsumerState<CreateStudyPlanScreen> createState() => _CreateStudyPlanScreenState();
}

class _CreateStudyPlanScreenState extends ConsumerState<CreateStudyPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Programming';
  StudyPlanType _selectedType = StudyPlanType.structured;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.intermediate;
  int _estimatedDurationDays = 30;
  int _dailyTimeMinutes = 30;
  DateTime _startDate = DateTime.now();
  
  final List<String> _topics = [];
  final TextEditingController _topicController = TextEditingController();
  
  bool _isLoading = false;

  final List<String> _categories = [
    'Programming',
    'Data Science',
    'Design',
    'Business',
    'Languages',
    'Mathematics',
    'Science',
    'Arts',
    'Music',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createStudyPlan,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildConfigurationSection(),
              const SizedBox(height: 24),
              _buildTopicsSection(),
              const SizedBox(height: 24),
              _buildScheduleSection(),
              const SizedBox(height: 32),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Study Plan Title',
                hintText: 'e.g., Learn Flutter Development',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what you want to learn...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StudyPlanType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Study Plan Type',
                border: OutlineInputBorder(),
              ),
              items: StudyPlanType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.displayName),
                      Text(
                        type.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DifficultyLevel>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty Level',
                border: OutlineInputBorder(),
              ),
              items: DifficultyLevel.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Topics to Learn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Add Topic',
                      hintText: 'e.g., Variables and Data Types',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) => _addTopic(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTopic,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_topics.isNotEmpty) ...[
              const Text(
                'Topics:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _topics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topic = entry.value;
                  return Chip(
                    label: Text(topic),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTopic(index),
                  );
                }).toList(),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No topics added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duration (days)'),
                      Slider(
                        value: _estimatedDurationDays.toDouble(),
                        min: 7,
                        max: 365,
                        divisions: 51,
                        label: '$_estimatedDurationDays days',
                        onChanged: (value) {
                          setState(() {
                            _estimatedDurationDays = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily time (minutes)'),
                      Slider(
                        value: _dailyTimeMinutes.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11,
                        label: '$_dailyTimeMinutes min',
                        onChanged: (value) {
                          setState(() {
                            _dailyTimeMinutes = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectStartDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createStudyPlan,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Create Study Plan',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  void _addTopic() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty && !_topics.contains(topic)) {
      setState(() {
        _topics.add(topic);
        _topicController.clear();
      });
    }
  }

  void _removeTopic(int index) {
    setState(() {
      _topics.removeAt(index);
    });
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _createStudyPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one topic')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a study plan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await StudyPlanService.instance.createStudyPlan(
        userId: authState.user!.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        estimatedDurationDays: _estimatedDurationDays,
        dailyTimeMinutes: _dailyTimeMinutes,
        topics: _topics,
        startDate: _startDate,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Study plan created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating study plan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
