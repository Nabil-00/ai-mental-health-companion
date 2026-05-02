import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final currentMessages = ref.read(chatMessagesProvider);
    final history = _buildRecentHistory(currentMessages, limit: 10);
    final firstName = await getFirstName(user);

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
        history: history,
        firstName: firstName,
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

List<Map<String, String>> _buildRecentHistory(
  List<ChatMessageModel> messages, {
  int limit = 10,
}) {
  final filtered = messages.where((message) {
    if (message.isLoading) return false;
    if ((message.metadata['error'] as bool?) == true) return false;
    if (message.content.trim().isEmpty) return false;
    return true;
  }).toList();

  final recent = filtered.length > limit
      ? filtered.sublist(filtered.length - limit)
      : filtered;

  return recent
      .map((message) {
        final role = message.sender == MessageSender.user
            ? 'user'
            : 'assistant';
        return {'role': role, 'content': message.content.trim()};
      })
      .toList(growable: false);
}

Future<String?> getFirstName(User user) async {
  final fromAuth = _sanitizeNameCandidate(user.displayName);
  if (fromAuth != null) return fromAuth;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data();
    if (data != null) {
      final candidates = [data['firstName'], data['displayName'], data['name']];
      for (final candidate in candidates) {
        final fromStore = _sanitizeNameCandidate(candidate?.toString());
        if (fromStore != null) return fromStore;
      }
    }
  } catch (_) {
    // Ignore Firestore read errors; fallback to email-based name.
  }

  // TODO: Persist chat/profile metadata for durable personalization across sessions.
  return _firstNameFromEmail(user.email);
}

String? _sanitizeNameCandidate(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final lowered = trimmed.toLowerCase();
  if (lowered == 'null' || lowered == 'undefined' || lowered == 'user') {
    return null;
  }

  final firstToken = trimmed.split(RegExp(r'\s+')).first;
  if (firstToken.contains('@')) return null;

  final clean = firstToken.replaceAll(RegExp(r"[^A-Za-z'-]"), '');
  if (clean.isEmpty) return null;

  return '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
}

String? _firstNameFromEmail(String? email) {
  if (email == null || !email.contains('@')) return null;
  final prefix = email.split('@').first.trim();
  if (prefix.isEmpty) return null;
  final token = prefix.replaceAll(RegExp(r'[._-]+'), ' ').split(' ').first;
  if (token.isEmpty) return null;
  final clean = token.replaceAll(RegExp(r"[^A-Za-z'-]"), '');
  if (clean.isEmpty) return null;
  return '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
}
