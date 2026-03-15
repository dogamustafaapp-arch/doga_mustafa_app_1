/// Represents a person stored in Firestore.
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.relationship,
    this.score = 0,
  });

  final String id;
  final String name;
  final String relationship;
  final int score;

  /// Display label for relationship (e.g. 'friend' → 'Friend').
  String get relationshipLabel => relationship.isEmpty
      ? ''
      : '${relationship[0].toUpperCase()}${relationship.substring(1)}';

  factory Person.fromFirestore(String id, Map<String, dynamic> data) {
    return Person(
      id: id,
      name: data['name'] as String? ?? '',
      relationship: data['relationship'] as String? ?? 'other',
      score: (data['score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'relationship': relationship,
        'score': score,
      };
}
