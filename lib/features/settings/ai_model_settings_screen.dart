import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/model_selector.dart';

class AIModelSettingsScreen extends ConsumerStatefulWidget {
  const AIModelSettingsScreen({super.key});

  @override
  ConsumerState<AIModelSettingsScreen> createState() => _AIModelSettingsScreenState();
}

class _AIModelSettingsScreenState extends ConsumerState<AIModelSettingsScreen> {
  String? selectedModel;
  List<ModelProfile> availableModels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      availableModels = ModelSelector.getAllModelProfiles();
      selectedModel = await AIService.instance.getCurrentModel();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Model Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickRecommendations(),
                  const SizedBox(height: 24),
                  _buildModelList(),
                  const SizedBox(height: 24),
                  _buildSelectedModelInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[600], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Choose Your AI Model',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select the AI model that best fits your learning style and needs. Each model has different strengths and capabilities.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRecommendationCard(
                'Best for Learning',
                'openai/chatgpt-4o-latest',
                Icons.school,
                Colors.green,
              ),
              _buildRecommendationCard(
                'Free Option',
                'deepseek/deepseek-r1-0528:free',
                Icons.money_off,
                Colors.orange,
              ),
              _buildRecommendationCard(
                'Fast Responses',
                'openai/gpt-3.5-turbo',
                Icons.speed,
                Colors.blue,
              ),
              _buildRecommendationCard(
                'Best Reasoning',
                'openai/gpt-4',
                Icons.psychology,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String modelId,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedModel == modelId;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _selectModel(modelId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? color.withValues(alpha: 0.1) : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                ModelSelector.getModelProfile(modelId)?.name ?? modelId,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Available Models',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...availableModels.map((model) => _buildModelCard(model)),
      ],
    );
  }

  Widget _buildModelCard(ModelProfile model) {
    final isSelected = selectedModel == model.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _selectModel(model.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              model.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildCostBadge(model.cost),
                            if (model.cost == ModelCost.free)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.provider,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                model.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildCapabilityChip('${model.maxTokens ~/ 1000}K tokens'),
                  _buildSpeedChip(model.speed),
                  ...model.capabilities.map((cap) => _buildCapabilityChip(
                        cap.name.toUpperCase(),
                      )),
                ],
              ),
              if (model.bestFor.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Best for: ${model.bestFor.join(', ')}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostBadge(ModelCost cost) {
    Color color;
    String text;
    
    switch (cost) {
      case ModelCost.free:
        color = Colors.green;
        text = 'FREE';
        break;
      case ModelCost.low:
        color = Colors.blue;
        text = 'LOW';
        break;
      case ModelCost.medium:
        color = Colors.orange;
        text = 'MED';
        break;
      case ModelCost.high:
        color = Colors.red;
        text = 'HIGH';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpeedChip(ModelSpeed speed) {
    Color color;
    String text;
    
    switch (speed) {
      case ModelSpeed.slow:
        color = Colors.red;
        text = 'SLOW';
        break;
      case ModelSpeed.medium:
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case ModelSpeed.fast:
        color = Colors.green;
        text = 'FAST';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCapabilityChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSelectedModelInfo() {
    if (selectedModel == null) return const SizedBox.shrink();
    
    final model = ModelSelector.getModelProfile(selectedModel!);
    if (model == null) return const SizedBox.shrink();
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Selected Model: ${model.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              model.strengthsDescription,
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
              ),
            ),
            if (model.limitations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Limitations: ${model.limitations.join(', ')}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectModel(String modelId) {
    setState(() {
      selectedModel = modelId;
    });
    
    // Save the selection (you would implement this based on your preferences system)
    _saveModelSelection(modelId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${ModelSelector.getModelProfile(modelId)?.name ?? modelId}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveModelSelection(String modelId) async {
    // TODO: Implement saving to user preferences
    // This could save to SharedPreferences, Firestore, or your user settings
    try {
      await AIService.instance.setModel(modelId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving model selection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
