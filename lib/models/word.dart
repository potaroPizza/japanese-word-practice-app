class WordExample {
  final String sentence;
  final String translation;

  WordExample({required this.sentence, required this.translation});

  factory WordExample.fromJson(Map<String, dynamic> json) {
    return WordExample(
      sentence: json['sentence'] as String,
      translation: json['translation'] as String,
    );
  }
}

class Word {
  final int id;
  final String? kanji;
  final String reading;
  final String meaning;
  final String level;
  final List<WordExample> examples;

  Word({
    required this.id,
    this.kanji,
    required this.reading,
    required this.meaning,
    required this.level,
    this.examples = const [],
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    final exList = json['examples'] as List<dynamic>?;
    return Word(
      id: json['id'] as int,
      kanji: json['kanji'] as String?,
      reading: json['reading'] as String,
      meaning: json['meaning'] as String,
      level: json['level'] as String,
      examples: exList?.map((e) => WordExample.fromJson(e)).toList() ?? [],
    );
  }

  String get displayWord => kanji ?? reading;
}
