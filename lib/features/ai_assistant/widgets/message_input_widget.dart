import 'package:flutter/material.dart';

class MessageInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isLoading;

  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = widget.controller.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Text input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: widget.isLoading 
                          ? 'AI is thinking...' 
                          : 'Ask me anything...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    enabled: !widget.isLoading,
                    onSubmitted: (_) => _handleSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: _isComposing && !widget.isLoading 
                      ? Colors.blue 
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isComposing && !widget.isLoading 
                      ? _handleSend 
                      : null,
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[600]!,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: _isComposing 
                              ? Colors.white 
                              : Colors.grey[600],
                          size: 20,
                        ),
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
