import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class QuizScreen extends StatefulWidget {
  final String level;

  const QuizScreen({super.key, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _sessionSize = 20;

  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();
  final Random _random = Random();

  List<Word> _allWords = [];
  List<Word> _sessionWords = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _streak = 0;
  int _maxStreak = 0;

  // Current question state
  List<String> _choices = [];
  int _correctChoiceIndex = -1;
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await _wordRepo.getWordsByLevel(widget.level);
    final shuffled = List<Word>.from(words)..shuffle(_random);
    setState(() {
      _allWords = words;
      _sessionWords = shuffled.take(_sessionSize).toList();
      _isLoading = false;
    });
    _generateChoices();
  }

  void _generateChoices() {
    if (_currentIndex >= _sessionWords.length) return;

    final currentWord = _sessionWords[_currentIndex];
    final correctMeaning = currentWord.meaning;

    // Collect wrong answers from same level, excluding the correct one
    final wrongMeanings = _allWords
        .where((w) => w.meaning != correctMeaning)
        .map((w) => w.meaning)
        .toSet()
        .toList()
      ..shuffle(_random);

    final choices = <String>[correctMeaning];
    for (final meaning in wrongMeanings) {
      if (choices.length >= 4) break;
      choices.add(meaning);
    }

    // Pad with placeholder if not enough unique meanings
    while (choices.length < 4) {
      choices.add('---');
    }

    choices.shuffle(_random);
    setState(() {
      _choices = choices;
      _correctChoiceIndex = choices.indexOf(correctMeaning);
      _selectedIndex = null;
      _answered = false;
    });
  }

  Future<void> _onChoiceSelected(int index) async {
    if (_answered) return;

    final word = _sessionWords[_currentIndex];
    final isCorrect = index == _correctChoiceIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    if (isCorrect) {
      await _studyRepo.markCorrect(widget.level, word.id);
      _correctCount++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
    } else {
      await _studyRepo.markIncorrect(widget.level, word.id);
      _incorrectCount++;
      _streak = 0;
    }

    // Delay before next question
    final delay = isCorrect ? 1000 : 2000;
    await Future.delayed(Duration(milliseconds: delay));

    if (!mounted) return;

    if (_currentIndex + 1 >= _sessionWords.length) {
      setState(() => _isSessionComplete = true);
    } else {
      setState(() => _currentIndex++);
      _generateChoices();
    }
  }

  void _restartSession() {
    final shuffled = List<Word>.from(_allWords)..shuffle(_random);
    setState(() {
      _sessionWords = shuffled.take(_sessionSize).toList();
      _currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _streak = 0;
      _maxStreak = 0;
      _isSessionComplete = false;
    });
    _generateChoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} Quiz'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3949AB)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    final word = _sessionWords[_currentIndex];
    final progress = (_currentIndex + 1) / _sessionWords.length;

    return SafeArea(
      child: Column(
        children: [
          // Progress + streak
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_sessionWords.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3949AB),
                      ),
                    ),
                    if (_streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('\uD83D\uDD25',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '$_streak streak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Text('$_correctCount',
                            style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600)),
                        Text(' / ',
                            style: TextStyle(color: Colors.grey[400])),
                        Text('$_incorrectCount',
                            style: TextStyle(
                                color: Colors.red[400],
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE8E0F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3949AB)),
                  ),
                ),
              ],
            ),
          ),

          // Question word
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (word.kanji != null) ...[
                    Text(
                      word.kanji!,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.reading,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else
                    Text(
                      word.reading,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Choices
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_choices.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildChoiceButton(index),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(int index) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0D8EE);
    Color textColor = const Color(0xFF1A237E);
    IconData? icon;

    if (_answered) {
      if (index == _correctChoiceIndex) {
        bgColor = Colors.green[50]!;
        borderColor = Colors.green[400]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
      } else if (index == _selectedIndex && index != _correctChoiceIndex) {
        bgColor = Colors.red[50]!;
        borderColor = Colors.red[400]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _answered ? null : () => _onChoiceSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _answered && index == _correctChoiceIndex
                        ? Colors.green[100]
                        : _answered &&
                                index == _selectedIndex &&
                                index != _correctChoiceIndex
                            ? Colors.red[100]
                            : const Color(0xFFF0EAFF),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _choices[index],
                    style: TextStyle(
                      fontSize: 17,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (icon != null)
                  Icon(icon,
                      color: index == _correctChoiceIndex
                          ? Colors.green[600]
                          : Colors.red[400],
                      size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final total = _correctCount + _incorrectCount;
    final accuracy = total > 0 ? (_correctCount / total * 100).round() : 0;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                accuracy >= 80
                    ? Icons.emoji_events
                    : accuracy >= 50
                        ? Icons.thumb_up
                        : Icons.sentiment_neutral,
                size: 80,
                color: const Color(0xFF3949AB),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quiz Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(Icons.check_circle, 'Correct', '$_correctCount / $total',
                  Colors.green[600]!),
              const SizedBox(height: 12),
              _buildStatRow(
                  Icons.percent, 'Accuracy', '$accuracy%', const Color(0xFF3949AB)),
              const SizedBox(height: 12),
              _buildStatRow(Icons.local_fire_department, 'Max Streak',
                  '$_maxStreak', Colors.orange[600]!),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3949AB),
                        side: const BorderSide(color: Color(0xFF3949AB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _restartSession,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3949AB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
