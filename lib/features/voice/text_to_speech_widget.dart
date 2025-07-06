import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/voice_service.dart';

// TTS state provider
final ttsStateProvider = StateNotifierProvider<TTSStateNotifier, TTSState>((ref) {
  final voiceService = VoiceService.instance;
  return TTSStateNotifier(voiceService);
});

class TextToSpeechWidget extends ConsumerStatefulWidget {
  final String text;
  final bool autoPlay;
  final Color? primaryColor;
  final double? speechRate;
  final double? volume;
  final double? pitch;
  final String? language;
  final bool showControls;
  final bool showProgress;

  const TextToSpeechWidget({
    super.key,
    required this.text,
    this.autoPlay = false,
    this.primaryColor,
    this.speechRate,
    this.volume,
    this.pitch,
    this.language,
    this.showControls = true,
    this.showProgress = false,
  });

  @override
  ConsumerState<TextToSpeechWidget> createState() => _TextToSpeechWidgetState();
}

class _TextToSpeechWidgetState extends ConsumerState<TextToSpeechWidget>
    with TickerProviderStateMixin {
  late AnimationController _speakingController;
  late Animation<double> _speakingAnimation;
  
  StreamSubscription<bool>? _speakingSubscription;
  Timer? _progressTimer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _speakingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _speakingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _speakingController,
      curve: Curves.easeInOut,
    ));

    _setupListeners();
    
    if (widget.autoPlay && widget.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _speak();
      });
    }
  }

  @override
  void dispose() {
    _speakingController.dispose();
    _speakingSubscription?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    final voiceService = VoiceService.instance;
    
    _speakingSubscription = voiceService.speakingStateStream.listen((isSpeaking) {
      if (isSpeaking) {
        _speakingController.repeat(reverse: true);
        if (widget.showProgress) {
          _startProgressTimer();
        }
      } else {
        _speakingController.stop();
        _speakingController.reset();
        _progressTimer?.cancel();
        setState(() {
          _progress = 0.0;
        });
      }
    });
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progress = 0.0;
    
    // Estimate speaking duration (rough calculation)
    final wordsPerMinute = 150; // Average speaking rate
    final words = widget.text.split(' ').length;
    final estimatedDuration = (words / wordsPerMinute) * 60; // in seconds
    
    const updateInterval = Duration(milliseconds: 100);
    final totalUpdates = (estimatedDuration * 1000 / updateInterval.inMilliseconds).round();
    
    var currentUpdate = 0;
    
    _progressTimer = Timer.periodic(updateInterval, (timer) {
      currentUpdate++;
      setState(() {
        _progress = (currentUpdate / totalUpdates).clamp(0.0, 1.0);
      });
      
      if (currentUpdate >= totalUpdates) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ttsState = ref.watch(ttsStateProvider);
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    if (!widget.showControls && !ttsState.isSpeaking) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ttsState.isSpeaking ? primaryColor : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayPauseButton(ttsState, primaryColor),
          
          if (widget.showProgress && ttsState.isSpeaking) ...[
            const SizedBox(width: 8),
            _buildProgressIndicator(primaryColor),
          ],
          
          if (ttsState.isSpeaking) ...[
            const SizedBox(width: 8),
            _buildStopButton(primaryColor),
          ],
          
          if (ttsState.error != null) ...[
            const SizedBox(width: 8),
            _buildErrorIcon(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(TTSState ttsState, Color primaryColor) {
    return AnimatedBuilder(
      animation: _speakingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: ttsState.isSpeaking ? _speakingAnimation.value : 1.0,
          child: InkWell(
            onTap: ttsState.isSpeaking ? _pause : _speak,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                ttsState.isSpeaking ? Icons.pause : Icons.volume_up,
                size: 20,
                color: ttsState.isSpeaking ? primaryColor : Colors.grey[600],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(Color primaryColor) {
    return SizedBox(
      width: 40,
      height: 4,
      child: LinearProgressIndicator(
        value: _progress,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }

  Widget _buildStopButton(Color primaryColor) {
    return InkWell(
      onTap: _stop,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.stop,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildErrorIcon(ThemeData theme) {
    return Tooltip(
      message: 'Text-to-speech error',
      child: Icon(
        Icons.error_outline,
        size: 16,
        color: Colors.red[600],
      ),
    );
  }

  void _speak() {
    if (widget.text.isEmpty) return;
    
    ref.read(ttsStateProvider.notifier).speak(
      widget.text,
      language: widget.language,
      speechRate: widget.speechRate,
      volume: widget.volume,
      pitch: widget.pitch,
    );
  }

  void _pause() {
    ref.read(ttsStateProvider.notifier).pause();
  }

  void _stop() {
    ref.read(ttsStateProvider.notifier).stop();
  }
}

// Compact TTS button for minimal UI
class TTSButton extends ConsumerWidget {
  final String text;
  final Color? color;
  final double size;
  final String? tooltip;

  const TTSButton({
    super.key,
    required this.text,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsStateProvider);
    final theme = Theme.of(context);
    final iconColor = color ?? theme.primaryColor;

    return Tooltip(
      message: tooltip ?? 'Read aloud',
      child: InkWell(
        onTap: () => _toggleSpeech(ref),
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          padding: EdgeInsets.all(size * 0.2),
          child: Icon(
            ttsState.isSpeaking ? Icons.volume_off : Icons.volume_up,
            size: size,
            color: ttsState.isSpeaking ? iconColor : iconColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  void _toggleSpeech(WidgetRef ref) {
    final ttsState = ref.read(ttsStateProvider);
    final notifier = ref.read(ttsStateProvider.notifier);
    
    if (ttsState.isSpeaking) {
      notifier.stop();
    } else {
      notifier.speak(text);
    }
  }
}

// TTS state management
class TTSState {
  final bool isSpeaking;
  final bool isInitialized;
  final String? currentText;
  final String? error;
  final List<String> availableLanguages;
  final List<Map<String, String>> availableVoices;

  const TTSState({
    this.isSpeaking = false,
    this.isInitialized = false,
    this.currentText,
    this.error,
    this.availableLanguages = const [],
    this.availableVoices = const [],
  });

  TTSState copyWith({
    bool? isSpeaking,
    bool? isInitialized,
    String? currentText,
    String? error,
    List<String>? availableLanguages,
    List<Map<String, String>>? availableVoices,
  }) {
    return TTSState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isInitialized: isInitialized ?? this.isInitialized,
      currentText: currentText ?? this.currentText,
      error: error,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      availableVoices: availableVoices ?? this.availableVoices,
    );
  }
}

class TTSStateNotifier extends StateNotifier<TTSState> {
  final VoiceService _voiceService;
  StreamSubscription<bool>? _speakingSubscription;
  StreamSubscription<VoiceError>? _errorSubscription;

  TTSStateNotifier(this._voiceService) : super(const TTSState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _speakingSubscription = _voiceService.speakingStateStream.listen((isSpeaking) {
        state = state.copyWith(isSpeaking: isSpeaking);
      });
      
      _errorSubscription = _voiceService.errorStream.listen((error) {
        if (error.type == VoiceErrorType.tts) {
          state = state.copyWith(error: error.message, isSpeaking: false);
        }
      });
      
      // Load available languages and voices
      final languages = await _voiceService.getAvailableLanguages();
      final voices = await _voiceService.getAvailableVoices();
      
      state = state.copyWith(
        isInitialized: true,
        availableLanguages: languages,
        availableVoices: voices,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize TTS: $e');
    }
  }

  Future<void> speak(
    String text, {
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!state.isInitialized) {
      state = state.copyWith(error: 'TTS not initialized');
      return;
    }

    try {
      state = state.copyWith(error: null, currentText: text);
      await _voiceService.speak(
        text,
        language: language,
        speechRate: speechRate,
        volume: volume,
        pitch: pitch,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to speak: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _voiceService.pauseSpeaking();
    } catch (e) {
      state = state.copyWith(error: 'Failed to pause: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _voiceService.stopSpeaking();
      state = state.copyWith(currentText: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop: $e');
    }
  }

  Future<void> configure({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    try {
      await _voiceService.configureTTS(
        language: language,
        speechRate: speechRate,
        volume: volume,
        pitch: pitch,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to configure TTS: $e');
    }
  }

  @override
  void dispose() {
    _speakingSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }
}
