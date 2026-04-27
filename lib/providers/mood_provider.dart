import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:buddy/models/mood_entry_model.dart';
import 'package:buddy/providers/auth_provider.dart';

final moodEntriesProvider = StreamProvider<List<MoodEntryModel>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('mood_entries')
      .where('userId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MoodEntryModel.fromJson(doc.data()))
            .toList(),
      );
});

final latestMoodEntryProvider = Provider<MoodEntryModel?>((ref) {
  final entries = ref.watch(moodEntriesProvider);
  return entries.valueOrNull?.firstOrNull;
});

class MoodNotifier extends StateNotifier<AsyncValue<List<MoodEntryModel>>> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  MoodNotifier(this.ref) : super(const AsyncValue.data([]));

  Future<MoodEntryModel> addMoodEntry({
    required MoodLevel mood,
    String note = '',
    Map<String, dynamic> tags = const {},
  }) async {
    final user = ref.read(userProvider);
    if (user == null) {
      throw Exception('You must be signed in to save mood entries');
    }

    final entry = MoodEntryModel(
      id: _uuid.v4(),
      userId: user.uid,
      mood: mood,
      note: note,
      tags: tags,
      timestamp: DateTime.now(),
    );

    final currentEntries = state.valueOrNull ?? const <MoodEntryModel>[];
    state = AsyncValue.data([entry, ...currentEntries]);

    final payload = entry.toJson();
    payload['timestamp'] = FieldValue.serverTimestamp();

    await _firestore.collection('mood_entries').doc(entry.id).set(payload);

    return entry;
  }

  Future<void> deleteMoodEntry(String id) async {
    await _firestore.collection('mood_entries').doc(id).delete();
  }
}

final moodNotifierProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<List<MoodEntryModel>>>((
      ref,
    ) {
      return MoodNotifier(ref);
    });
