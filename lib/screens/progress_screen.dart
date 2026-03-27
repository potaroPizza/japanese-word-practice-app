import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();

  bool _isLoading = true;

  // 레벨별 진도 데이터
  final List<_LevelProgressData> _progressList = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    for (final level in WordRepository.levels) {
      final words = await _wordRepo.getWordsByLevel(level);
      final totalCount = words.length;
      final progress = await _studyRepo.getLevelProgress(level, totalCount);
      final incorrectIds = await _studyRepo.getIncorrectWordIds(level, totalCount);

      // 틀린 단어 목록
      final incorrectWords = <Word>[];
      for (final id in incorrectIds) {
        final match = words.where((w) => w.id == id);
        if (match.isNotEmpty) {
          incorrectWords.add(match.first);
        }
      }

      final studied = progress['studied'] ?? 0;
      final correct = progress['correct'] ?? 0;
      final accuracy = studied == 0 ? 0.0 : correct / studied;

      _progressList.add(_LevelProgressData(
        level: level,
        totalWords: totalCount,
        studiedWords: studied,
        accuracy: accuracy,
        incorrectWords: incorrectWords,
      ));
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text(
          '진도 확인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _progressList.length,
              itemBuilder: (context, index) {
                return _buildProgressCard(_progressList[index]);
              },
            ),
    );
  }

  Widget _buildProgressCard(_LevelProgressData data) {
    final completionRate = data.totalWords == 0
        ? 0.0
        : data.studiedWords / data.totalWords;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          // 레벨 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JLPT ${data.level}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 프로그레스 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    minHeight: 10,
                    backgroundColor: Colors.indigo.shade50,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.indigo.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 상세 정보
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.book_outlined,
                      '${data.studiedWords} / ${data.totalWords}',
                      '학습 단어',
                    ),
                    const SizedBox(width: 16),
                    _buildInfoChip(
                      Icons.check_circle_outline,
                      '${(data.accuracy * 100).toStringAsFixed(1)}%',
                      '정답률',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 틀린 단어 목록
          if (data.incorrectWords.isNotEmpty)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                title: Text(
                  '틀린 단어 (${data.incorrectWords.length}개)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: data.incorrectWords.map((word) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  word.displayWord,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                              ),
                              if (word.kanji != null)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    word.reading,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  word.meaning,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '틀린 단어 없음',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.indigo.shade400),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelProgressData {
  final String level;
  final int totalWords;
  final int studiedWords;
  final double accuracy;
  final List<Word> incorrectWords;

  _LevelProgressData({
    required this.level,
    required this.totalWords,
    required this.studiedWords,
    required this.accuracy,
    required this.incorrectWords,
  });
}
