import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/person_model.dart';

const String _collectionId = 'people';

final class PeopleFirestoreService {
  PeopleFirestoreService._();
  static final PeopleFirestoreService instance = PeopleFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collectionId);

  /// Stream of all people. Use this in the UI to react to changes.
  Stream<List<Person>> watchPeople() {
    return _col.snapshots().map((snap) {
      return snap.docs
          .map((d) => Person.fromFirestore(d.id, d.data()))
          .toList();
    });
  }

  /// Add a new person. Score defaults to 0.
  Future<void> addPerson({
    required String name,
    required String relationship,
    int score = 0,
  }) async {
    await _col.add({
      'name': name.trim(),
      'relationship': relationship,
      'score': score,
    });
  }
}
