import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import 'progress_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'fill_blank_screen.dart';
import 'matching_screen.dart';
import 'listening_screen.dart';
import 'speed_ox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_ModeData> _modes = [
    _ModeData(
      name: '플래시카드',
      icon: Icons.style_outlined,
      color: const Color(0xFF5C6BC0),
      screenBuilder: (level) => FlashcardScreen(level: level),
    ),
    _ModeData(
      name: '객관식 퀴즈',
      icon: Icons.quiz_outlined,
      color: const Color(0xFF7E57C2),
      screenBuilder: (level) => QuizScreen(level: level),
    ),
    _ModeData(
      name: '빈칸 채우기',
      icon: Icons.edit_note_outlined,
      color: const Color(0xFF9575CD),
      screenBuilder: (level) => FillBlankScreen(level: level),
    ),
    _ModeData(
      name: '매칭 게임',
      icon: Icons.grid_view_rounded,
      color: const Color(0xFF26A69A),
      screenBuilder: (level) => MatchingScreen(level: level),
    ),
    _ModeData(
      name: '리스닝 퀴즈',
      icon: Icons.headphones_rounded,
      color: const Color(0xFFEF5350),
      screenBuilder: (level) => ListeningScreen(level: level),
    ),
    _ModeData(
      name: '스피드 O/X',
      icon: Icons.speed_rounded,
      color: const Color(0xFFFF9800),
      screenBuilder: (level) => SpeedOxScreen(level: level),
    ),
  ];

  void _showLevelDialog(String modeName, Color color, Widget Function(String level) screenBuilder) {
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
                '$modeName - 레벨 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              ...WordRepository.levels.map((level) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => screenBuilder(level)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'JLPT $level',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )),
            ],
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
        child: Column(
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
                  '학습 모드를 선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 모드 카드 그리드
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: _modes.map((mode) => _buildModeCard(mode)).toList(),
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

  Widget _buildModeCard(_ModeData mode) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showLevelDialog(mode.name, mode.color, mode.screenBuilder),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [mode.color, mode.color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mode.icon, size: 32, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  mode.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class _ModeData {
  final String name;
  final IconData icon;
  final Color color;
  final Widget Function(String level) screenBuilder;

  const _ModeData({
    required this.name,
    required this.icon,
    required this.color,
    required this.screenBuilder,
  });
}
