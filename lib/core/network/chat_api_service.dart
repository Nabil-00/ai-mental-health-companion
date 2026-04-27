import 'package:dio/dio.dart';
import 'package:buddy/models/chat_message_model.dart';
import 'package:buddy/core/constants/constants.dart';
import 'api_client.dart';

class ChatApiService {
  final ApiClient _client = ApiClient();

  Future<ChatMessageModel> sendChatMessage({
    required String message,
    required String userId,
    MoodContext? moodContext,
  }) async {
    try {
      final response = await _client.dio.post(
        AppConstants.aiProxyEndpoint,
        data: {
          'message': message,
          'userId': userId,
          if (moodContext != null) 'moodContext': moodContext.toJson(),
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Empty response from server');
      }

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        content: data['reply'] as String? ?? 'I\'m here to support you.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ChatMessageModel> sendMockMessage({
    required String message,
    required String userId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final mockReplies = [
      "I hear you. How does that make you feel?",
      "Thank you for sharing that with me. Let's talk more about it.",
      "I understand. It's okay to feel that way.",
      "I'm here to support you. Would you like to explore this further?",
      "That's an important reflection. How long have you been feeling this way?",
    ];

    final reply = mockReplies[DateTime.now().millisecond % mockReplies.length];

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: message.toLowerCase().contains('sad')
          ? "I'm sorry you're feeling this way. Let me help you work through this."
          : reply,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Unauthorized. Please sign in again.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('Request failed: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
}

class MoodContext {
  final String currentMood;
  final String targetMood;
  final DateTime timestamp;

  MoodContext({
    required this.currentMood,
    required this.targetMood,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'currentMood': currentMood,
    'targetMood': targetMood,
    'timestamp': timestamp.toIso8601String(),
  };
}
