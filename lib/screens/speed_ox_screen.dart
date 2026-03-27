import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class SpeedOxScreen extends StatefulWidget {
  final String level;

  const SpeedOxScreen({super.key, required this.level});

  @override
  State<SpeedOxScreen> createState() => _SpeedOxScreenState();
}

class _SpeedOxScreenState extends State<SpeedOxScreen> {
  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();
  final Random _random = Random();

  List<Word> _allWords = [];
  Word? _currentWord;
  String _displayedMeaning = '';
  bool _isCorrectPair = false;
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _remainingMs = 60000;
  Timer? _timer;
  Color? _flashColor;
  bool _isLoading = true;
  bool _isSessionComplete = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final words = await _wordRepo.getWordsByLevel(widget.level);
    setState(() {
      _allWords = words;
      _isLoading = false;
    });
    _startGame();
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _remainingMs -= 100;
      if (_remainingMs <= 0) {
        _remainingMs = 0;
        _isSessionComplete = true;
        timer.cancel();
      }
      setState(() {});
    });
    _generateQuestion();
  }

  void _generateQuestion() {
    _currentWord = _allWords[_random.nextInt(_allWords.length)];
    _isCorrectPair = _random.nextBool();

    if (_isCorrectPair) {
      _displayedMeaning = _currentWord!.meaning;
    } else {
      Word wrongWord;
      do {
        wrongWord = _allWords[_random.nextInt(_allWords.length)];
      } while (wrongWord.meaning == _currentWord!.meaning);
      _displayedMeaning = wrongWord.meaning;
    }
    setState(() {});
  }

  void _onAnswer(bool userSaidCorrect) {
    if (_isSessionComplete) return;

    final isRight = (userSaidCorrect == _isCorrectPair);

    if (isRight) {
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;
      _score += (_combo >= 5) ? 2 : 1;
      _correctCount++;
      _flashColor = Colors.green;
      _studyRepo.markCorrect(widget.level, _currentWord!.id);
    } else {
      _combo = 0;
      _score = (_score - 1).clamp(0, 999999);
      _incorrectCount++;
      _flashColor = Colors.red;
      _studyRepo.markIncorrect(widget.level, _currentWord!.id);
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || _isSessionComplete) return;
      setState(() => _flashColor = null);
      _generateQuestion();
    });
  }

  void _restartSession() {
    setState(() {
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _remainingMs = 60000;
      _flashColor = null;
      _isSessionComplete = false;
    });
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} 스피드 O/X'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildGameView(),
    );
  }

  Widget _buildGameView() {
    final word = _currentWord;
    if (word == null) return const SizedBox.shrink();

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          border: _flashColor != null
              ? Border.all(color: _flashColor!, width: 4)
              : null,
        ),
        child: Column(
          children: [
            // Timer bar + score + combo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _remainingMs / 60000,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFFFE0B2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF9800)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '점수: $_score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      Text(
                        '${(_remainingMs / 1000).ceil()}초',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _combo >= 5
                              ? Colors.orange[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _combo >= 5
                                ? Colors.orange[300]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          '\uD83D\uDD25 $_combo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _combo >= 5
                                ? Colors.orange[700]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Question card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word.displayWord,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        if (word.kanji != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            word.reading,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          _displayedMeaning,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37474F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Combo indicator
            if (_combo >= 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '\uD83D\uDD25 $_combo Combo! +2점',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),

            // O/X buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Material(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onAnswer(true),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.green[300]!, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.circle_outlined,
                                    size: 36, color: Colors.green[600]),
                                const SizedBox(height: 4),
                                Text(
                                  'O',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Material(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onAnswer(false),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.red[300]!, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded,
                                    size: 36, color: Colors.red[600]),
                                const SizedBox(height: 4),
                                Text(
                                  'X',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.speed_rounded,
                size: 80,
                color: Color(0xFFFF9800),
              ),
              const SizedBox(height: 24),
              const Text(
                '학습 완료!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(
                  Icons.star, '최종 점수', '$_score', const Color(0xFFFF9800)),
              const SizedBox(height: 12),
              _buildStatRow(Icons.check_circle, '정답', '$_correctCount',
                  Colors.green[600]!),
              const SizedBox(height: 12),
              _buildStatRow(
                  Icons.cancel, '오답', '$_incorrectCount', Colors.red[400]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.local_fire_department, '최대 콤보',
                  '$_maxCombo', Colors.orange[600]!),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('돌아가기'),
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
                      label: const Text('다시하기'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
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

  Widget _buildStatRow(
      IconData icon, String label, String value, Color color) {
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
