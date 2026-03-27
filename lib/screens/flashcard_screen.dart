import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class FlashcardScreen extends StatefulWidget {
  final String level;

  const FlashcardScreen({super.key, required this.level});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  static const int _sessionSize = 20;

  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();

  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  int _correctCount = 0;
  int _incorrectCount = 0;

  // Swipe state
  double _dragOffset = 0;
  bool _isSwiping = false;

  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipController.addListener(() {
      if (_flipAnimation.value >= 0.5 && _showFront == !_isFlipped) {
        setState(() => _showFront = _isFlipped);
      }
      setState(() {});
    });
    _loadWords();
  }

  @override
  void dispose() {
    _flipController.dispose();
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

  void _flipCard() {
    if (_isSwiping) return;
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _onSwipeComplete(bool isCorrect) async {
    final word = _words[_currentIndex];
    if (isCorrect) {
      await _studyRepo.markCorrect(widget.level, word.id);
      _correctCount++;
    } else {
      await _studyRepo.markIncorrect(widget.level, word.id);
      _incorrectCount++;
    }

    if (_currentIndex + 1 >= _words.length) {
      setState(() => _isSessionComplete = true);
    } else {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _showFront = true;
        _dragOffset = 0;
      });
      _flipController.reset();
    }
  }

  void _restartSession() {
    setState(() {
      _words.shuffle(Random());
      _currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _isFlipped = false;
      _showFront = true;
      _isSessionComplete = false;
      _dragOffset = 0;
    });
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} Flashcard'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3949AB)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildCardView(),
    );
  }

  Widget _buildCardView() {
    final progress = (_currentIndex + 1) / _words.length;

    return SafeArea(
      child: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                        Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text('$_correctCount',
                            style: TextStyle(
                                color: Colors.green[600], fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Icon(Icons.cancel, size: 18, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text('$_incorrectCount',
                            style: TextStyle(
                                color: Colors.red[400], fontWeight: FontWeight.w600)),
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                  ),
                ),
              ],
            ),
          ),

          // Swipe hint
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 14, color: Colors.red[300]),
                Text(' moreu-m ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text('|',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                Text(' algo iss-eum ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Icon(Icons.arrow_forward, size: 14, color: Colors.green[300]),
              ],
            ),
          ),

          // Card
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                onHorizontalDragStart: (_) {
                  _isSwiping = true;
                },
                onHorizontalDragUpdate: (details) {
                  setState(() => _dragOffset += details.delta.dx);
                },
                onHorizontalDragEnd: (details) {
                  _isSwiping = false;
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (_dragOffset.abs() > screenWidth * 0.3) {
                    _onSwipeComplete(_dragOffset > 0);
                  } else {
                    setState(() => _dragOffset = 0);
                  }
                },
                child: AnimatedContainer(
                  duration: _isSwiping
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translateByDouble(_dragOffset, 0, 0, 0)
                    ..rotateZ(_dragOffset * 0.001),
                  child: Stack(
                    children: [
                      _buildCard(),
                      // Swipe overlay
                      if (_dragOffset.abs() > 30)
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _dragOffset > 0
                                    ? Colors.green.withValues(alpha: 0.6)
                                    : Colors.red.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _dragOffset > 0 ? Icons.check_circle : Icons.cancel,
                                size: 64,
                                color: _dragOffset > 0
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.red.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom hint
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              _isFlipped ? '← swipe to answer →' : 'Tap to flip',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final word = _words[_currentIndex];
    final angle = _flipAnimation.value * pi;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxHeight: 360),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: angle < pi / 2
            ? _buildCardFace(word, isFront: true)
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi),
                child: _buildCardFace(word, isFront: false),
              ),
      ),
    );
  }

  Widget _buildCardFace(Word word, {required bool isFront}) {
    return Container(
      decoration: BoxDecoration(
        color: isFront ? Colors.white : const Color(0xFF3949AB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: isFront
              ? Column(
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
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
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    Icon(Icons.touch_app, size: 24, color: Colors.grey[400]),
                  ],
                )
              : Text(
                  word.meaning,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
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
                'Session Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(Icons.check_circle, 'Correct',
                  '$_correctCount', Colors.green[600]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.cancel, 'Incorrect',
                  '$_incorrectCount', Colors.red[400]!),
              const SizedBox(height: 12),
              _buildStatRow(Icons.percent, 'Accuracy',
                  '$accuracy%', const Color(0xFF3949AB)),
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
                  fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
