import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word.dart';

class WordRepository {
  final Map<String, List<Word>> _cache = {};

  static const List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  Future<List<Word>> getWordsByLevel(String level) async {
    if (_cache.containsKey(level)) {
      return _cache[level]!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/words/${level.toLowerCase()}.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    final words = jsonList.map((j) => Word.fromJson(j)).toList();
    _cache[level] = words;
    return words;
  }

  Future<int> getWordCount(String level) async {
    final words = await getWordsByLevel(level);
    return words.length;
  }
}
