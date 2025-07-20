import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entry.dart';

class FirestoreService {
  final CollectionReference entriesCollection =
      FirebaseFirestore.instance.collection('entries');

  Future<void> addEntry(Entry entry) async {
    await entriesCollection.add(entry.toMap());
  }

  Stream<List<Entry>> getEntriesForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return entriesCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Entry.fromDoc(doc)).toList());
  }

  Future<void> deleteEntry(String id) async {
    await entriesCollection.doc(id).delete();
  }

  Future<void> updateEntry(Entry entry) async {
    await entriesCollection.doc(entry.id).update(entry.toMap());
  }
}

