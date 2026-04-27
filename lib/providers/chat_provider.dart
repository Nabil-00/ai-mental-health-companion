import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buddy/models/chat_message_model.dart';
import 'package:buddy/services/firebase_service.dart';
import 'package:buddy/providers/auth_provider.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageModel>>((ref) {
      return ChatMessagesNotifier();
    });

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageModel>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessageModel message) {
    state = [...state, message];
  }

  void updateMessage(ChatMessageModel message) {
    state = [
      for (final msg in state)
        if (msg.id == message.id) message else msg,
    ];
  }

  void clearMessages() {
    state = [];
  }
}

final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<AsyncValue<ChatMessageModel?>> {
  final Ref ref;

  ChatNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage(String content) async {
    final message = content.trim();
    if (message.isEmpty) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      content: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);

    ref.read(chatLoadingProvider.notifier).state = true;
    state = const AsyncValue.loading();
    try {
      final response = await ApiProxyService.sendMessage(
        message: message,
        userId: user.uid,
      );
      final aiMessage = ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        userId: user.uid,
        content: response['reply'] as String? ?? 'I\'m here to support you.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(aiMessage);
      state = AsyncValue.data(aiMessage);
    } catch (e, st) {
      final errorMessage = ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        userId: user.uid,
        content: 'Buddy is unavailable right now. Please try again.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        metadata: const {'error': true},
      );
      ref.read(chatMessagesProvider.notifier).addMessage(errorMessage);
      state = AsyncValue.error(e, st);
    } finally {
      ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  void clearChat() {
    ref.read(chatMessagesProvider.notifier).clearMessages();
    state = const AsyncValue.data(null);
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<ChatMessageModel?>>((ref) {
      return ChatNotifier(ref);
    });
