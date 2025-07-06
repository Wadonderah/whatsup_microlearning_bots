import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/voice_service.dart';

// Voice service provider
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService.instance;
});

// Voice state provider
final voiceStateProvider = StateNotifierProvider<VoiceStateNotifier, VoiceState>((ref) {
  final voiceService = ref.watch(voiceServiceProvider);
  return VoiceStateNotifier(voiceService);
});

class VoiceInputWidget extends ConsumerStatefulWidget {
  final Function(String) onTextReceived;
  final bool enabled;
  final String? hint;
  final Color? primaryColor;
  final Color? backgroundColor;

  const VoiceInputWidget({
    super.key,
    required this.onTextReceived,
    this.enabled = true,
    this.hint,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  ConsumerState<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends ConsumerState<VoiceInputWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  StreamSubscription<String>? _speechSubscription;
  StreamSubscription<bool>? _listeningSubscription;
  StreamSubscription<VoiceError>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _setupListeners();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _speechSubscription?.cancel();
    _listeningSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    final voiceService = ref.read(voiceServiceProvider);
    
    _speechSubscription = voiceService.speechResultStream.listen((text) {
      if (text.isNotEmpty) {
        widget.onTextReceived(text);
      }
    });
    
    _listeningSubscription = voiceService.listeningStateStream.listen((isListening) {
      if (isListening) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
        _pulseController.reset();
        _waveController.reset();
      }
    });
    
    _errorSubscription = voiceService.errorStream.listen((error) {
      _showErrorSnackBar(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceStateProvider);
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;
    final backgroundColor = widget.backgroundColor ?? theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (voiceState.isListening) ...[
            _buildListeningIndicator(primaryColor),
            const SizedBox(height: 16),
          ],
          
          _buildVoiceButton(voiceState, primaryColor),
          
          if (widget.hint != null && !voiceState.isListening) ...[
            const SizedBox(height: 8),
            Text(
              widget.hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (voiceState.lastRecognizedText.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRecognizedText(voiceState.lastRecognizedText, theme),
          ],
          
          if (voiceState.error != null) ...[
            const SizedBox(height: 12),
            _buildErrorMessage(voiceState.error!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildListeningIndicator(Color primaryColor) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final animationValue = (_waveAnimation.value - delay).clamp(0.0, 1.0);
              final height = 20 + (animationValue * 30);
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildVoiceButton(VoiceState voiceState, Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: voiceState.isListening ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.enabled ? _toggleListening : null,
            onLongPress: widget.enabled ? _startListening : null,
            onLongPressEnd: widget.enabled ? (_) => _stopListening() : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: voiceState.isListening 
                    ? primaryColor 
                    : (widget.enabled ? primaryColor.withValues(alpha: 0.1) : Colors.grey[300]),
                shape: BoxShape.circle,
                border: Border.all(
                  color: voiceState.isListening 
                      ? primaryColor.withValues(alpha: 0.3)
                      : primaryColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                voiceState.isListening ? Icons.mic : Icons.mic_none,
                size: 32,
                color: voiceState.isListening 
                    ? Colors.white 
                    : (widget.enabled ? primaryColor : Colors.grey[600]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecognizedText(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.record_voice_over, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleListening() {
    final voiceState = ref.read(voiceStateProvider);
    if (voiceState.isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    ref.read(voiceStateProvider.notifier).startListening();
  }

  void _stopListening() {
    ref.read(voiceStateProvider.notifier).stopListening();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Voice state management
class VoiceState {
  final bool isListening;
  final bool isInitialized;
  final String lastRecognizedText;
  final String? error;

  const VoiceState({
    this.isListening = false,
    this.isInitialized = false,
    this.lastRecognizedText = '',
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isInitialized,
    String? lastRecognizedText,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      lastRecognizedText: lastRecognizedText ?? this.lastRecognizedText,
      error: error,
    );
  }
}

class VoiceStateNotifier extends StateNotifier<VoiceState> {
  final VoiceService _voiceService;
  StreamSubscription<String>? _speechSubscription;
  StreamSubscription<bool>? _listeningSubscription;
  StreamSubscription<VoiceError>? _errorSubscription;

  VoiceStateNotifier(this._voiceService) : super(const VoiceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _voiceService.initialize();
      
      _speechSubscription = _voiceService.speechResultStream.listen((text) {
        state = state.copyWith(lastRecognizedText: text, error: null);
      });
      
      _listeningSubscription = _voiceService.listeningStateStream.listen((isListening) {
        state = state.copyWith(isListening: isListening);
      });
      
      _errorSubscription = _voiceService.errorStream.listen((error) {
        state = state.copyWith(error: error.message, isListening: false);
      });
      
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize voice service: $e');
    }
  }

  Future<void> startListening() async {
    if (!state.isInitialized) {
      state = state.copyWith(error: 'Voice service not initialized');
      return;
    }

    try {
      state = state.copyWith(error: null);
      await _voiceService.startListening();
    } catch (e) {
      state = state.copyWith(error: 'Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _voiceService.stopListening();
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop listening: $e');
    }
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    _listeningSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }
}
