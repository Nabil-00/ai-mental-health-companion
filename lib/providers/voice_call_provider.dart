import 'package:buddy/providers/auth_provider.dart';
import 'package:buddy/providers/chat_provider.dart';
import 'package:buddy/services/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceCallMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  const VoiceCallMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class VoiceCallState {
  final bool isListening;
  final bool isThinking;
  final bool isSpeaking;
  final String transcriptText;
  final String lastRecognizedText;
  final String? errorMessage;
  final List<VoiceCallMessage> callMessages;

  const VoiceCallState({
    this.isListening = false,
    this.isThinking = false,
    this.isSpeaking = false,
    this.transcriptText = '',
    this.lastRecognizedText = '',
    this.errorMessage,
    this.callMessages = const [],
  });

  VoiceCallState copyWith({
    bool? isListening,
    bool? isThinking,
    bool? isSpeaking,
    String? transcriptText,
    String? lastRecognizedText,
    String? errorMessage,
    bool clearError = false,
    List<VoiceCallMessage>? callMessages,
  }) {
    return VoiceCallState(
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      transcriptText: transcriptText ?? this.transcriptText,
      lastRecognizedText: lastRecognizedText ?? this.lastRecognizedText,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      callMessages: callMessages ?? this.callMessages,
    );
  }
}

final voiceCallProvider =
    StateNotifierProvider.autoDispose<VoiceCallNotifier, VoiceCallState>((ref) {
      final notifier = VoiceCallNotifier(ref);
      ref.onDispose(notifier.disposeResources);
      return notifier;
    });

class VoiceCallNotifier extends StateNotifier<VoiceCallState> {
  final Ref ref;
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  String _recognizedWords = '';

  VoiceCallNotifier(this.ref) : super(const VoiceCallState());

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setStartHandler(() {
      state = state.copyWith(isSpeaking: true, clearError: true);
    });
    _tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
    _tts.setCancelHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
    _tts.setErrorHandler((_) {
      state = state.copyWith(
        isSpeaking: false,
        errorMessage: 'Buddy could not speak the response right now.',
      );
    });
    _initialized = true;
  }

  Future<void> startListening() async {
    await initialize();

    if (state.isThinking) {
      state = state.copyWith(
        errorMessage: 'Buddy is still thinking. Please wait a moment.',
      );
      return;
    }

    if (state.isSpeaking) {
      await _tts.stop();
      state = state.copyWith(isSpeaking: false);
    }

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      state = state.copyWith(
        isListening: false,
        errorMessage: 'Buddy needs microphone permission to hear you.',
      );
      return;
    }

    final available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );

    if (!available) {
      state = state.copyWith(
        isListening: false,
        errorMessage: 'Speech recognition is unavailable on this device.',
      );
      return;
    }

    _recognizedWords = '';
    state = state.copyWith(
      isListening: true,
      isThinking: false,
      transcriptText: '',
      lastRecognizedText: '',
      clearError: true,
    );

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListeningAndProcess();
      return;
    }
    await startListening();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    _recognizedWords = words;
    state = state.copyWith(
      lastRecognizedText: words,
      transcriptText: words,
      clearError: true,
    );
  }

  void _onSpeechStatus(String status) {
    if ((status == 'done' || status == 'notListening') && state.isListening) {
      stopListeningAndProcess();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (error.permanent) {
      state = state.copyWith(
        isListening: false,
        errorMessage: 'I had trouble hearing you. Please try again.',
      );
    }
  }

  Future<void> stopListeningAndProcess() async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    final recognizedText = _recognizedWords.trim();
    state = state.copyWith(isListening: false, transcriptText: '');

    if (recognizedText.isEmpty) {
      state = state.copyWith(
        lastRecognizedText: '',
        errorMessage: 'I didn\'t catch that. Try again.',
      );
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      state = state.copyWith(errorMessage: 'Please sign in to use voice chat.');
      return;
    }

    final updatedMessages = [
      ...state.callMessages,
      VoiceCallMessage(
        role: 'user',
        content: recognizedText,
        timestamp: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      callMessages: updatedMessages,
      isThinking: true,
      lastRecognizedText: recognizedText,
      clearError: true,
    );

    try {
      final firstName = await getFirstName(user);
      final history = _buildVoiceHistory(updatedMessages, limit: 10);
      final response = await ApiProxyService.sendMessage(
        message: recognizedText,
        userId: user.uid,
        history: history,
        firstName: firstName,
      );

      final reply = (response['reply'] as String?)?.trim().isNotEmpty == true
          ? (response['reply'] as String).trim()
          : 'I\'m here with you. Can you share a little more?';

      final withReply = [
        ...updatedMessages,
        VoiceCallMessage(
          role: 'assistant',
          content: reply,
          timestamp: DateTime.now(),
        ),
      ];

      state = state.copyWith(callMessages: withReply, isThinking: false);
      await _speakReply(reply);
    } catch (_) {
      final fallback = 'Buddy is unavailable right now. Please try again.';
      final withFallback = [
        ...updatedMessages,
        VoiceCallMessage(
          role: 'assistant',
          content: fallback,
          timestamp: DateTime.now(),
        ),
      ];
      state = state.copyWith(
        callMessages: withFallback,
        isThinking: false,
        errorMessage: 'Connection issue. Buddy could not respond right now.',
      );
    } finally {
      _recognizedWords = '';
    }
  }

  Future<void> _speakReply(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSpeaking: true, clearError: true);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopActiveAudio() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    await _tts.stop();
    state = state.copyWith(
      isListening: false,
      isThinking: false,
      isSpeaking: false,
      transcriptText: '',
      lastRecognizedText: '',
    );
  }

  Future<void> endCall() async {
    await stopActiveAudio();
  }

  void resetSession() {
    _recognizedWords = '';
    state = const VoiceCallState();
  }

  Future<void> disposeResources() async {
    await stopActiveAudio();
  }
}

List<Map<String, String>> _buildVoiceHistory(
  List<VoiceCallMessage> messages, {
  int limit = 10,
}) {
  final filtered = messages
      .where((message) {
        final content = message.content.trim();
        if (content.isEmpty) return false;
        if (message.role != 'user' && message.role != 'assistant') return false;
        return true;
      })
      .toList(growable: false);

  final recent = filtered.length > limit
      ? filtered.sublist(filtered.length - limit)
      : filtered;

  return recent
      .map(
        (message) => {'role': message.role, 'content': message.content.trim()},
      )
      .toList(growable: false);
}
