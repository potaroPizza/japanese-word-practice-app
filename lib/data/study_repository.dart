import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_record.dart';

class StudyRepository {
  static const String _prefix = 'study_';
  static const String _lockKey = 'pin_lock_until';
  static const String _failCountKey = 'pin_fail_count';

  Future<StudyRecord> getRecord(String level, int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${level}_$wordId';
    final data = prefs.getString(key);

    if (data != null) {
      return StudyRecord.fromJson(json.decode(data));
    }

    return StudyRecord(
      wordKey: key,
      lastStudied: DateTime.now(),
    );
  }

  Future<void> saveRecord(String level, int wordId, StudyRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${level}_$wordId';
    await prefs.setString(key, json.encode(record.toJson()));
  }

  Future<void> markCorrect(String level, int wordId) async {
    final record = await getRecord(level, wordId);
    record.correctCount++;
    record.lastStudied = DateTime.now();
    await saveRecord(level, wordId, record);
  }

  Future<void> markIncorrect(String level, int wordId) async {
    final record = await getRecord(level, wordId);
    record.incorrectCount++;
    record.lastStudied = DateTime.now();
    await saveRecord(level, wordId, record);
  }

  Future<Map<String, int>> getLevelProgress(String level, int totalWords) async {
    final prefs = await SharedPreferences.getInstance();
    int studied = 0;
    int correct = 0;

    for (int i = 1; i <= totalWords; i++) {
      final key = '$_prefix${level}_$i';
      final data = prefs.getString(key);
      if (data != null) {
        final record = StudyRecord.fromJson(json.decode(data));
        if (record.totalAttempts > 0) {
          studied++;
          if (record.accuracy >= 0.5) correct++;
        }
      }
    }

    return {'studied': studied, 'correct': correct, 'total': totalWords};
  }

  Future<List<int>> getIncorrectWordIds(String level, int totalWords) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> incorrectIds = [];

    for (int i = 1; i <= totalWords; i++) {
      final key = '$_prefix${level}_$i';
      final data = prefs.getString(key);
      if (data != null) {
        final record = StudyRecord.fromJson(json.decode(data));
        if (record.incorrectCount > record.correctCount) {
          incorrectIds.add(i);
        }
      }
    }

    return incorrectIds;
  }

  // PIN 잠금 관련
  Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getString(_lockKey);
    if (lockUntil == null) return false;

    final lockTime = DateTime.parse(lockUntil);
    if (DateTime.now().isBefore(lockTime)) return true;

    await prefs.remove(_lockKey);
    await prefs.remove(_failCountKey);
    return false;
  }

  Future<int> getFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failCountKey) ?? 0;
  }

  Future<void> incrementFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_failCountKey) ?? 0) + 1;
    await prefs.setInt(_failCountKey, count);

    if (count >= 5) {
      final lockUntil = DateTime.now().add(const Duration(hours: 24));
      await prefs.setString(_lockKey, lockUntil.toIso8601String());
    }
  }

  Future<void> resetFailCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failCountKey);
  }

  Future<DateTime?> getLockUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getString(_lockKey);
    if (lockUntil == null) return null;
    return DateTime.parse(lockUntil);
  }
}
