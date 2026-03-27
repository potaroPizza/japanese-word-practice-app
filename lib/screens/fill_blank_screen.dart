import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class FillBlankScreen extends StatefulWidget {
  final String level;

  const FillBlankScreen({super.key, required this.level});

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  static const int _sessionSize = 20;

  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Word> _sessionWords = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  int _correctCount = 0;
  int _incorrectCount = 0;

  // 현재 문제 상태
  String _sentenceWithBlank = '';
  String _answer = '';
  String _fullSentence = '';
  String _translation = '';
  bool _answered = false;
  bool _isCorrect = false;
  bool _hintUsed = false;
  String _hint = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final allWords = await _wordRepo.getWordsByLevel(widget.level);
    // 예문이 있는 단어만 필터링
    final wordsWithExamples = allWords.where((w) => w.examples.isNotEmpty).toList();
    wordsWithExamples.shuffle(_random);
    setState(() {
      _sessionWords = wordsWithExamples.take(_sessionSize).toList();
      _isLoading = false;
    });
    if (_sessionWords.isNotEmpty) _generateQuestion();
  }

  void _generateQuestion() {
    final word = _sessionWords[_currentIndex];
    final example = word.examples[_random.nextInt(word.examples.length)];

    _fullSentence = example.sentence;
    _translation = example.translation;

    // 문장에서 단어(kanji 또는 reading)를 빈칸으로 치환
    final target = word.kanji ?? word.reading;
    if (_fullSentence.contains(target)) {
      _sentenceWithBlank = _fullSentence.replaceFirst(target, '＿＿＿');
      _answer = target;
    } else if (_fullSentence.contains(word.reading)) {
      _sentenceWithBlank = _fullSentence.replaceFirst(word.reading, '＿＿＿');
      _answer = word.reading;
    } else {
      // 문장에 단어가 포함되지 않는 경우 reading을 정답으로
      _sentenceWithBlank = '＿＿＿';
      _answer = word.reading;
    }

    _hint = _answer.isNotEmpty ? _answer.substring(0, 1) : '';

    setState(() {
      _controller.clear();
      _answered = false;
      _isCorrect = false;
      _hintUsed = false;
    });
  }

  void _checkAnswer() {
    if (_answered) return;
    final input = _controller.text.trim().replaceAll(' ', '').replaceAll('\u3000', '');
    final correct = _answer.replaceAll(' ', '').replaceAll('\u3000', '');

    final word = _sessionWords[_currentIndex];
    final isCorrect = input == correct || input == word.reading || (word.kanji != null && input == word.kanji);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _studyRepo.markCorrect(widget.level, word.id);
      _correctCount++;
    } else {
      _studyRepo.markIncorrect(widget.level, word.id);
      _incorrectCount++;
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _sessionWords.length) {
      setState(() => _isSessionComplete = true);
    } else {
      setState(() => _currentIndex++);
      _generateQuestion();
      _focusNode.requestFocus();
    }
  }

  void _showHint() {
    setState(() => _hintUsed = true);
  }

  void _restartSession() {
    _sessionWords.shuffle(_random);
    setState(() {
      _currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _isSessionComplete = false;
    });
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} 빈칸 채우기'),
        backgroundColor: const Color(0xFF9575CD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
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
          // Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_sessionWords.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9575CD)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text('$_correctCount', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Icon(Icons.cancel, size: 18, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text('$_incorrectCount', style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w600)),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9575CD)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 번역 (힌트)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _translation,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 빈칸 문장
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9575CD).withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      _sentenceWithBlank,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E), height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 뜻 표시
                  Text(
                    '뜻: ${word.meaning}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // 힌트
                  if (_hintUsed && !_answered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Text('힌트: $_hint...', style: TextStyle(fontSize: 16, color: Colors.amber[800])),
                    ),

                  const SizedBox(height: 16),

                  // 입력 필드
                  if (!_answered)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22),
                            decoration: InputDecoration(
                              hintText: '정답 입력',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF9575CD), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: (_) => _checkAnswer(),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // 버튼들
                  if (!_answered)
                    Row(
                      children: [
                        if (!_hintUsed)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showHint,
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('힌트'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber[700],
                                side: BorderSide(color: Colors.amber[700]!),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        if (!_hintUsed) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _checkAnswer,
                            icon: const Icon(Icons.check),
                            label: const Text('확인'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF9575CD),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // 정답/오답 피드백
                  if (_answered) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isCorrect ? Colors.green[400]! : Colors.red[400]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect ? Colors.green[600] : Colors.red[600],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isCorrect ? '정답!' : '오답',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          if (!_isCorrect) ...[
                            const SizedBox(height: 8),
                            Text(
                              '정답: $_answer',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red[800]),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _fullSentence,
                            style: const TextStyle(fontSize: 18, color: Color(0xFF1A237E)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('다음'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF9575CD),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
                accuracy >= 80 ? Icons.emoji_events : accuracy >= 50 ? Icons.thumb_up : Icons.sentiment_neutral,
                size: 80,
                color: const Color(0xFF9575CD),
              ),
              const SizedBox(height: 24),
              const Text('학습 완료!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 32),
              _buildStatRow(Icons.check_circle, '정답', '$_correctCount', Colors.green[600]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.cancel, '오답', '$_incorrectCount', Colors.red[400]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.percent, '정답률', '$accuracy%', const Color(0xFF9575CD)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        backgroundColor: const Color(0xFF9575CD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
