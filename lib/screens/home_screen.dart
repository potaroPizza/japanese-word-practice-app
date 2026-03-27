import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import 'progress_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'fill_blank_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();

  // 레벨별 데이터: { level: { wordCount, studied, correct } }
  final Map<String, Map<String, int>> _levelData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    for (final level in WordRepository.levels) {
      final count = await _wordRepo.getWordCount(level);
      final progress = await _studyRepo.getLevelProgress(level, count);
      _levelData[level] = {
        'wordCount': count,
        'studied': progress['studied'] ?? 0,
        'correct': progress['correct'] ?? 0,
        'total': progress['total'] ?? count,
      };
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _showModeDialog(String level) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$level 학습 모드',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(height: 20),
              _buildModeButton(
                icon: Icons.style_outlined,
                label: '플래시카드',
                color: const Color(0xFF5C6BC0),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(level: level),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildModeButton(
                icon: Icons.quiz_outlined,
                label: '객관식 퀴즈',
                color: const Color(0xFF7E57C2),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(level: level),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildModeButton(
                icon: Icons.edit_note_outlined,
                label: '빈칸 채우기',
                color: const Color(0xFF9575CD),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FillBlankScreen(level: level),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
              )
            : Column(
                children: [
                  // 상단 타이틀
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 32,
                          color: Colors.indigo.shade600,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '일본어 단어 연습',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '학습할 레벨을 선택하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 레벨 카드 목록
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: WordRepository.levels.length,
                      itemBuilder: (context, index) {
                        final level = WordRepository.levels[index];
                        final data = _levelData[level]!;
                        final wordCount = data['wordCount']!;
                        final studied = data['studied']!;
                        final progress =
                            wordCount == 0 ? 0.0 : studied / wordCount;

                        return _buildLevelCard(
                          level: level,
                          wordCount: wordCount,
                          progress: progress,
                        );
                      },
                    ),
                  ),

                  // 하단 진도 확인 버튼
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProgressScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          '진도 확인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLevelCard({
    required String level,
    required int wordCount,
    required double progress,
  }) {
    // 레벨별 그라데이션 색상
    final colors = {
      'N5': [const Color(0xFF5C6BC0), const Color(0xFF7986CB)],
      'N4': [const Color(0xFF7E57C2), const Color(0xFF9575CD)],
      'N3': [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
      'N2': [const Color(0xFF4527A0), const Color(0xFF5E35B1)],
      'N1': [const Color(0xFF311B92), const Color(0xFF4527A0)],
    };

    final levelColors =
        colors[level] ?? [const Color(0xFF3F51B5), const Color(0xFF5C6BC0)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () => _showModeDialog(level),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: levelColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JLPT $level',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$wordCount단어',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 프로그레스 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '학습 진도 ${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
