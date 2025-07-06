import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_speech/text_to_speech.dart';

class VoiceService {
  static VoiceService? _instance;
  static VoiceService get instance => _instance ??= VoiceService._();

  VoiceService._();

  // Speech to Text
  late stt.SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  // Text to Speech
  late TextToSpeech _textToSpeech;
  bool _ttsEnabled = false;
  bool _isSpeaking = false;

  // Stream controllers
  final StreamController<String> _speechResultController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStateController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _speakingStateController =
      StreamController<bool>.broadcast();
  final StreamController<VoiceError> _errorController =
      StreamController<VoiceError>.broadcast();

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;

  // Streams
  Stream<String> get speechResultStream => _speechResultController.stream;
  Stream<bool> get listeningStateStream => _listeningStateController.stream;
  Stream<bool> get speakingStateStream => _speakingStateController.stream;
  Stream<VoiceError> get errorStream => _errorController.stream;

  /// Initialize voice services
  Future<void> initialize() async {
    try {
      await _initializeSpeechToText();
      await _initializeTextToSpeech();
      log('Voice service initialized successfully');
    } catch (e) {
      log('Error initializing voice service: $e');
      _errorController.add(VoiceError(
        type: VoiceErrorType.initialization,
        message: 'Failed to initialize voice service: $e',
      ));
    }
  }

  /// Initialize Speech to Text
  Future<void> _initializeSpeechToText() async {
    _speechToText = stt.SpeechToText();

    // Request microphone permission
    final permissionStatus = await Permission.microphone.request();
    if (permissionStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    // Initialize speech to text
    _speechEnabled = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );

    if (!_speechEnabled) {
      throw Exception('Speech recognition not available');
    }
  }

  /// Initialize Text to Speech
  Future<void> _initializeTextToSpeech() async {
    try {
      _textToSpeech = TextToSpeech();

      // Check if TTS is available on this platform
      if (kIsWeb || !Platform.isWindows) {
        _ttsEnabled = true;
        log('Text-to-speech initialized successfully');
      } else {
        // For Windows, TTS might not be available or have issues
        _ttsEnabled = false;
        log('Text-to-speech disabled on Windows platform');
      }
    } catch (e) {
      _ttsEnabled = false;
      log('Error initializing text-to-speech: $e');
      _errorController.add(VoiceError(
        type: VoiceErrorType.tts,
        message: 'TTS initialization failed: $e',
      ));
    }
  }

  /// Start listening for speech
  Future<void> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_speechEnabled) {
      _errorController.add(VoiceError(
        type: VoiceErrorType.speechToText,
        message: 'Speech recognition not available',
      ));
      return;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: localeId ?? 'en_US',
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
        ),
      );
    } catch (e) {
      _errorController.add(VoiceError(
        type: VoiceErrorType.speechToText,
        message: 'Failed to start listening: $e',
      ));
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Speak text using TTS
  Future<void> speak(
    String text, {
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!_ttsEnabled) {
      _errorController.add(VoiceError(
        type: VoiceErrorType.tts,
        message: 'Text-to-speech not available on this platform',
      ));
      return;
    }

    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      _isSpeaking = true;
      _speakingStateController.add(true);

      // Use the new text_to_speech package
      await _textToSpeech.speak(text);

      // Simulate completion (since text_to_speech doesn't have callbacks)
      _isSpeaking = false;
      _speakingStateController.add(false);
    } catch (e) {
      _isSpeaking = false;
      _speakingStateController.add(false);
      _errorController.add(VoiceError(
        type: VoiceErrorType.tts,
        message: 'Failed to speak: $e',
      ));
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      try {
        await _textToSpeech.stop();
      } catch (e) {
        log('Error stopping TTS: $e');
      }
      _isSpeaking = false;
      _speakingStateController.add(false);
    }
  }

  /// Pause speaking
  Future<void> pauseSpeaking() async {
    if (_isSpeaking) {
      // text_to_speech package doesn't support pause, so we stop instead
      await stopSpeaking();
    }
  }

  /// Get available languages for TTS
  Future<List<String>> getAvailableLanguages() async {
    if (!_ttsEnabled) return [];

    try {
      // text_to_speech package doesn't provide language enumeration
      // Return common languages
      return [
        'en-US',
        'en-GB',
        'es-ES',
        'fr-FR',
        'de-DE',
        'it-IT',
        'pt-BR',
        'ja-JP',
        'ko-KR',
        'zh-CN',
      ];
    } catch (e) {
      log('Error getting available languages: $e');
      return [];
    }
  }

  /// Get available voices for TTS
  Future<List<Map<String, String>>> getAvailableVoices() async {
    if (!_ttsEnabled) return [];

    try {
      // text_to_speech package doesn't provide voice enumeration
      // Return empty list for now
      return [];
    } catch (e) {
      log('Error getting available voices: $e');
      return [];
    }
  }

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_speechEnabled) return [];

    try {
      return await _speechToText.locales();
    } catch (e) {
      log('Error getting available locales: $e');
      return [];
    }
  }

  /// Check if speech recognition is available
  Future<bool> checkSpeechAvailability() async {
    try {
      return await stt.SpeechToText().initialize();
    } catch (e) {
      return false;
    }
  }

  /// Check microphone permission
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Configure TTS settings
  Future<void> configureTTS({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!_ttsEnabled) return;

    try {
      // text_to_speech package doesn't support configuration
      // Settings are applied per speak() call
      log('TTS configuration requested but not supported by current package');
    } catch (e) {
      log('Error configuring TTS: $e');
    }
  }

  /// Speech status callback
  void _onSpeechStatus(String status) {
    log('Speech status: $status');

    final wasListening = _isListening;
    _isListening = status == 'listening';

    if (wasListening != _isListening) {
      _listeningStateController.add(_isListening);
    }
  }

  /// Speech error callback
  void _onSpeechError(dynamic error) {
    log('Speech error: $error');

    _isListening = false;
    _listeningStateController.add(false);

    _errorController.add(VoiceError(
      type: VoiceErrorType.speechToText,
      message: 'Speech recognition error: $error',
    ));
  }

  /// Speech result callback
  void _onSpeechResult(dynamic result) {
    if (result != null) {
      _lastWords = result.recognizedWords ?? '';
      _speechResultController.add(_lastWords);

      log('Speech result: $_lastWords (confidence: ${result.confidence})');
    }
  }

  /// Dispose resources
  void dispose() {
    _speechResultController.close();
    _listeningStateController.close();
    _speakingStateController.close();
    _errorController.close();

    if (_speechToText.isListening) {
      _speechToText.stop();
    }

    if (_isSpeaking) {
      try {
        _textToSpeech.stop();
      } catch (e) {
        log('Error stopping TTS during disposal: $e');
      }
    }
  }
}

/// Voice error types
enum VoiceErrorType {
  initialization,
  speechToText,
  tts,
  permission,
}

/// Voice error class
class VoiceError {
  final VoiceErrorType type;
  final String message;
  final DateTime timestamp;

  VoiceError({
    required this.type,
    required this.message,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'VoiceError(${type.name}): $message';
  }
}

/// Voice service configuration
class VoiceConfig {
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
  final Duration listenTimeout;
  final Duration pauseTimeout;
  final bool partialResults;

  const VoiceConfig({
    this.language = 'en-US',
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.listenTimeout = const Duration(seconds: 30),
    this.pauseTimeout = const Duration(seconds: 3),
    this.partialResults = true,
  });
}
