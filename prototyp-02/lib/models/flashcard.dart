import 'package:meta/meta.dart';

@immutable
class Flashcard {
  final String id;
  final String front;
  final String back;
  final List<String> tags;
  final int proficiency;
  final DateTime lastUpdated;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.tags = const [],
    this.proficiency = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'tags': tags,
      'proficiency': proficiency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    int? proficiency,
    List<String>? tags,
    DateTime? lastUpdated,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      proficiency: proficiency ?? this.proficiency,
      tags: tags ?? this.tags,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    try {
      return Flashcard(
        id: json['id'] as String? ?? 'unknown_id',
        front: json['front'] as String? ?? '',
        back: json['back'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        proficiency: json['proficiency'] as int? ?? 0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse Flashcard from JSON: $e');
    }
  }

  @override
  String toString() {
    return 'Flashcard(id: $id, front: $front, proficiency: $proficiency)';
  }

  Flashcard _modifyProficiency(int newP) {
    return copyWith(proficiency: newP, lastUpdated: DateTime.now());
  }

  Flashcard increaseProficiency() {
    var newP = proficiency < 4 ? proficiency + 1 : proficiency;
    return _modifyProficiency(newP);
  }

  Flashcard decreaseProficiency() {
    var newP = proficiency > 0 ? proficiency - 1 : proficiency;
    return _modifyProficiency(newP);
  }
}
