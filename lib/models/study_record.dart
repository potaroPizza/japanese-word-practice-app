class StudyRecord {
  final String wordKey;
  int correctCount;
  int incorrectCount;
  DateTime lastStudied;

  StudyRecord({
    required this.wordKey,
    this.correctCount = 0,
    this.incorrectCount = 0,
    required this.lastStudied,
  });

  factory StudyRecord.fromJson(Map<String, dynamic> json) {
    return StudyRecord(
      wordKey: json['wordKey'] as String,
      correctCount: json['correctCount'] as int,
      incorrectCount: json['incorrectCount'] as int,
      lastStudied: DateTime.parse(json['lastStudied'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordKey': wordKey,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'lastStudied': lastStudied.toIso8601String(),
    };
  }

  int get totalAttempts => correctCount + incorrectCount;
  double get accuracy => totalAttempts == 0 ? 0 : correctCount / totalAttempts;
}
