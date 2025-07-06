import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/prompt_template.dart';
import 'providers/ai_chat_provider.dart';
import 'widgets/chat_message_widget.dart';
import 'widgets/message_input_widget.dart';
import 'widgets/prompt_template_selector.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _showTemplates = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    ref.read(aiChatProvider.notifier).sendMessage(content);
    _messageController.clear();

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _useTemplate(PromptTemplate template, Map<String, String> values) {
    final prompt = template.generatePrompt(values);
    _sendMessage(prompt);
    setState(() {
      _showTemplates = false;
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearMessages();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning Assistant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showTemplates ? Icons.chat : Icons.auto_awesome),
            onPressed: () {
              setState(() {
                _showTemplates = !_showTemplates;
              });
            },
            tooltip: _showTemplates ? 'Show Chat' : 'Show Templates',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: chatState.messages.isNotEmpty ? _clearChat : null,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          if (chatState.hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error ?? 'Connection error',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: _showTemplates
                ? PromptTemplateSelector(
                    onTemplateSelected: _useTemplate,
                  )
                : _buildChatInterface(chatState),
          ),

          // Message Input
          if (!_showTemplates)
            MessageInputWidget(
              controller: _messageController,
              onSendMessage: _sendMessage,
              isLoading: chatState.isLoading,
            ),
        ],
      ),
    );
  }

  Widget _buildChatInterface(AIChatState chatState) {
    if (chatState.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return ChatMessageWidget(
          message: message,
          onRetry: message.hasError
              ? () => ref.read(aiChatProvider.notifier).retryMessage(message.id)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Learning Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything or use a template to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickActionButton(
                icon: Icons.auto_awesome,
                label: 'Templates',
                onTap: () => setState(() => _showTemplates = true),
              ),
              const SizedBox(width: 16),
              _buildQuickActionButton(
                icon: Icons.lightbulb_outline,
                label: 'Ask Question',
                onTap: () => _messageController.text = 'Explain ',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
