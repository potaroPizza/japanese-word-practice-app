class Word {
  final int id;
  final String? kanji;
  final String reading;
  final String meaning;
  final String level;

  Word({
    required this.id,
    this.kanji,
    required this.reading,
    required this.meaning,
    required this.level,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      kanji: json['kanji'] as String?,
      reading: json['reading'] as String,
      meaning: json['meaning'] as String,
      level: json['level'] as String,
    );
  }

  String get displayWord => kanji ?? reading;
}
