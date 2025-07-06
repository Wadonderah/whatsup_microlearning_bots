import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/ai_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final AIMessage message;
  final VoidCallback? onRetry;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with role and timestamp
                _buildMessageHeader(context),
                const SizedBox(height: 4),
                
                // Message bubble
                _buildMessageBubble(context),
                
                // Actions (copy, retry, etc.)
                if (!message.isLoading) _buildMessageActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    IconData icon;
    Color color;

    if (message.isUser) {
      icon = Icons.person;
      color = Colors.blue;
    } else if (message.isSystem) {
      icon = Icons.info_outline;
      color = Colors.orange;
    } else {
      icon = Icons.psychology;
      color = Colors.green;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _buildMessageHeader(BuildContext context) {
    String role;
    if (message.isUser) {
      role = 'You';
    } else if (message.isSystem) {
      role = 'System';
    } else {
      role = 'AI Assistant';
    }

    return Row(
      children: [
        Text(
          role,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimestamp(message.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (message.isUser) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (message.isSystem) {
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange[800]!;
    } else {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.black87;
    }

    if (message.hasError) {
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red[800]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: message.hasError 
            ? Border.all(color: Colors.red.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isLoading)
            _buildLoadingIndicator()
          else
            _buildMessageContent(textColor),
          
          if (message.hasError) ...[
            const SizedBox(height: 8),
            _buildErrorIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    return SelectableText(
      message.content,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Thinking...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorIndicator() {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          size: 16,
          color: Colors.red[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message.error ?? 'An error occurred',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Copy button
          _buildActionButton(
            icon: Icons.copy,
            tooltip: 'Copy message',
            onPressed: () => _copyToClipboard(context),
          ),
          
          // Retry button (for failed messages)
          if (message.hasError && onRetry != null) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.refresh,
              tooltip: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
