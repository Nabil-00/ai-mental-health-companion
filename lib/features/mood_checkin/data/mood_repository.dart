import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/mood_entry_model.dart';

abstract class MoodRepository {
  Future<void> saveMoodEntry(MoodEntryModel entry);
  Future<void> deleteMoodEntry(String id);
  Stream<List<MoodEntryModel>> watchMoodEntries(String userId);
  Future<MoodEntryModel?> getLatestMoodEntry(String userId);
}

class FirestoreMoodRepository implements MoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveMoodEntry(MoodEntryModel entry) async {
    final payload = entry.toJson();
    payload['timestamp'] = FieldValue.serverTimestamp();

    await _firestore.collection('mood_entries').doc(entry.id).set(payload);
  }

  @override
  Future<void> deleteMoodEntry(String id) async {
    await _firestore.collection('mood_entries').doc(id).delete();
  }

  @override
  Stream<List<MoodEntryModel>> watchMoodEntries(String userId) {
    return _firestore
        .collection('mood_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MoodEntryModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<MoodEntryModel?> getLatestMoodEntry(String userId) async {
    final snapshot = await _firestore
        .collection('mood_entries')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MoodEntryModel.fromJson(snapshot.docs.first.data());
  }
}
