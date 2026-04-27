import '../../../models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ChatMessageModel> sendMessage({
    required String content,
    required String userId,
    List<Map<String, dynamic>>? moodContext,
  });
  Future<void> saveChatSession(String userId, List<ChatMessageModel> messages);
  Stream<List<ChatMessageModel>> watchChatHistory(String userId);
}

abstract class LlmService {
  Future<Map<String, dynamic>> sendChatRequest({
    required String message,
    required String userId,
    Map<String, dynamic>? context,
  });
}
