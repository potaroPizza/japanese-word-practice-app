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
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  int _correctCount = 0;
  int _incorrectCount = 0;

  // Answer state
  bool _answered = false;
  bool _isCorrect = false;
  bool _hintShown = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _inputController.addListener(() {
      // Trigger rebuild to update Check button enabled state
      if (!_answered) setState(() {});
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final allWords = await _wordRepo.getWordsByLevel(widget.level);
    final shuffled = List<Word>.from(allWords)..shuffle(Random());
    setState(() {
      _words = shuffled.take(_sessionSize).toList();
      _isLoading = false;
    });
  }

  String _normalize(String input) {
    // Remove whitespace (half-width and full-width)
    return input
        .replaceAll(RegExp(r'\s'), '') // half-width spaces
        .replaceAll('\u3000', '')      // full-width space
        .trim();
  }

  Future<void> _checkAnswer() async {
    if (_answered) return;

    final word = _words[_currentIndex];
    final userInput = _normalize(_inputController.text);
    final correctAnswer = _normalize(word.reading);

    final isCorrect = userInput == correctAnswer;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      await _studyRepo.markCorrect(widget.level, word.id);
      _correctCount++;
    } else {
      await _studyRepo.markIncorrect(widget.level, word.id);
      _incorrectCount++;
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _words.length) {
      setState(() => _isSessionComplete = true);
    } else {
      setState(() {
        _currentIndex++;
        _answered = false;
        _isCorrect = false;
        _hintShown = false;
        _inputController.clear();
      });
      _focusNode.requestFocus();
    }
  }

  void _showHint() {
    if (_answered) return;
    setState(() => _hintShown = true);
  }

  void _restartSession() {
    setState(() {
      _words.shuffle(Random());
      _currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _answered = false;
      _isCorrect = false;
      _hintShown = false;
      _isSessionComplete = false;
      _inputController.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} Fill in the Blank'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3949AB)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    final word = _words[_currentIndex];
    final progress = (_currentIndex + 1) / _words.length;

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentIndex + 1} / ${_words.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3949AB),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 18, color: Colors.green[600]),
                              const SizedBox(width: 4),
                              Text('$_correctCount',
                                  style: TextStyle(
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              Icon(Icons.cancel,
                                  size: 18, color: Colors.red[400]),
                              const SizedBox(width: 4),
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

                const SizedBox(height: 32),

                // Korean meaning (question)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'What is the reading for:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        word.meaning,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (word.kanji != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          word.kanji!,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hint
                if (_hintShown && !_answered)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Hint: ${word.reading.characters.first}...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _answered
                            ? (_isCorrect
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15))
                            : const Color(0xFF3949AB).withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    enabled: !_answered,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type in hiragana',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: _answered
                          ? (_isCorrect ? Colors.green[50] : Colors.red[50])
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0D8EE), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF3949AB), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                    onSubmitted: (_) => _answered ? _nextQuestion() : _checkAnswer(),
                  ),
                ),

                const SizedBox(height: 20),

                // Result feedback
                if (_answered) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isCorrect
                            ? Colors.green[300]!
                            : Colors.red[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.cancel,
                              color: _isCorrect
                                  ? Colors.green[600]
                                  : Colors.red[500],
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect ? 'Correct!' : 'Incorrect',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect
                                    ? Colors.green[700]
                                    : Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                        if (!_isCorrect) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Answer: ${word.reading}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action buttons
                Row(
                  children: [
                    if (!_answered) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _hintShown ? null : _showHint,
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Hint'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber[700],
                            side: BorderSide(
                                color: _hintShown
                                    ? Colors.grey[300]!
                                    : Colors.amber[400]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _inputController.text.trim().isEmpty
                              ? null
                              : _checkAnswer,
                          icon: const Icon(Icons.check),
                          label: const Text('Check'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF3949AB),
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _nextQuestion,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            _currentIndex + 1 >= _words.length
                                ? 'View Results'
                                : 'Next',
                          ),
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

                const SizedBox(height: 32),
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
                'Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(Icons.check_circle, 'Correct',
                  '$_correctCount / $total', Colors.green[600]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.cancel, 'Incorrect', '$_incorrectCount',
                  Colors.red[400]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.percent, 'Accuracy', '$accuracy%',
                  const Color(0xFF3949AB)),
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
