import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class MatchingScreen extends StatefulWidget {
  final String level;
  const MatchingScreen({super.key, required this.level});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();

  List<Word> _sessionWords = [];
  List<_Tile> _tiles = [];
  Set<int> _selectedIndices = {};
  Set<int> _matchedIndices = {};
  Set<int> _wrongIndices = {};
  int _attempts = 0;
  bool _isChecking = false;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  final Stopwatch _stopwatch = Stopwatch();
  String _elapsedDisplay = '0:00';
  Timer? _timer;

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
    final allWords = await _wordRepo.getWordsByLevel(widget.level);
    final shuffled = List<Word>.from(allWords)..shuffle(Random());
    _sessionWords = shuffled.take(6).toList();

    final tiles = <_Tile>[];
    for (int i = 0; i < _sessionWords.length; i++) {
      final word = _sessionWords[i];
      tiles.add(_Tile(text: word.displayWord, wordIndex: i, isJapanese: true));
      tiles.add(_Tile(text: word.meaning, wordIndex: i, isJapanese: false));
    }
    tiles.shuffle(Random());

    setState(() {
      _tiles = tiles;
      _isLoading = false;
    });

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionComplete) {
        timer.cancel();
        return;
      }
      final seconds = _stopwatch.elapsed.inSeconds;
      setState(() => _elapsedDisplay = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}');
    });
  }

  void _onTileTap(int index) {
    if (_isChecking) return;
    if (_matchedIndices.contains(index)) return;
    if (_selectedIndices.contains(index)) return;

    setState(() {
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _checkMatch();
    }
  }

  Future<void> _checkMatch() async {
    _isChecking = true;
    _attempts++;

    final indices = _selectedIndices.toList();
    final tile1 = _tiles[indices[0]];
    final tile2 = _tiles[indices[1]];

    final isMatch = tile1.wordIndex == tile2.wordIndex &&
        tile1.isJapanese != tile2.isJapanese;

    if (isMatch) {
      final word = _sessionWords[tile1.wordIndex];
      await _studyRepo.markCorrect(widget.level, word.id);

      setState(() {
        _matchedIndices.addAll(indices);
        _selectedIndices.clear();
      });

      if (_matchedIndices.length == _tiles.length) {
        _stopwatch.stop();
        setState(() => _isSessionComplete = true);
      }
    } else {
      setState(() {
        _wrongIndices = Set.from(indices);
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      setState(() {
        _wrongIndices.clear();
        _selectedIndices.clear();
      });
    }

    _isChecking = false;
  }

  void _restartSession() {
    _timer?.cancel();
    _stopwatch.reset();

    final tiles = <_Tile>[];
    for (int i = 0; i < _sessionWords.length; i++) {
      final word = _sessionWords[i];
      tiles.add(_Tile(text: word.displayWord, wordIndex: i, isJapanese: true));
      tiles.add(_Tile(text: word.meaning, wordIndex: i, isJapanese: false));
    }
    tiles.shuffle(Random());

    setState(() {
      _tiles = tiles;
      _selectedIndices = {};
      _matchedIndices = {};
      _wrongIndices = {};
      _attempts = 0;
      _isChecking = false;
      _isSessionComplete = false;
      _elapsedDisplay = '0:00';
    });

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionComplete) {
        timer.cancel();
        return;
      }
      final seconds = _stopwatch.elapsed.inSeconds;
      setState(() => _elapsedDisplay = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text('${widget.level} 매칭 게임'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildGameView(),
    );
  }

  Widget _buildGameView() {
    return SafeArea(
      child: Column(
        children: [
          // 상단 정보 바
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '경과 시간: $_elapsedDisplay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '시도: $_attempts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 타일 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(_tiles.length, (index) => _buildTile(index)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index) {
    final tile = _tiles[index];
    final isMatched = _matchedIndices.contains(index);
    final isSelected = _selectedIndices.contains(index);
    final isWrong = _wrongIndices.contains(index);

    Color backgroundColor;
    Border border;
    Color textColor;

    if (isMatched) {
      backgroundColor = Colors.green[50]!;
      border = Border.all(color: Colors.green, width: 2);
      textColor = Colors.green[700]!;
    } else if (isWrong) {
      backgroundColor = tile.isJapanese ? const Color(0xFFE8EAF6) : const Color(0xFFE0F2F1);
      border = Border.all(color: Colors.red, width: 3);
      textColor = Colors.grey[800]!;
    } else if (isSelected) {
      backgroundColor = tile.isJapanese ? const Color(0xFFE8EAF6) : const Color(0xFFE0F2F1);
      border = Border.all(color: const Color(0xFF26A69A), width: 3);
      textColor = Colors.grey[800]!;
    } else {
      backgroundColor = tile.isJapanese ? const Color(0xFFE8EAF6) : const Color(0xFFE0F2F1);
      border = Border.all(color: Colors.grey[300]!, width: 1.5);
      textColor = Colors.grey[800]!;
    }

    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  tile.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: tile.isJapanese ? 18 : 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (isMatched)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, size: 18, color: Colors.green[700]),
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
              const Icon(Icons.grid_view_rounded, size: 80, color: Color(0xFF26A69A)),
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
              _buildStatRow(Icons.timer_outlined, '경과 시간', _elapsedDisplay, const Color(0xFF26A69A)),
              const SizedBox(height: 12),
              _buildStatRow(Icons.touch_app_outlined, '시도 횟수', '$_attempts', Colors.orange[700]!),
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
                        backgroundColor: const Color(0xFF26A69A),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile {
  final String text;
  final int wordIndex;
  final bool isJapanese;

  _Tile({required this.text, required this.wordIndex, required this.isJapanese});
}
