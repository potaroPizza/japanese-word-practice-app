# 신규 학습 모드 추가 및 홈 화면 재구성

## 개요

기존 3가지 모드(플래시카드, 객관식, 빈칸채우기)에 3가지 모드(매칭, 리스닝, 스피드 O/X)를 추가하고,
홈 화면 구조를 **모드 선택 -> 레벨 선택** 순서로 변경한다.

## 현재 코드베이스 상태

### 파일 구조
```
lib/
├── main.dart                    # MaterialApp, fontFamily: 'NotoSansJP', home: PinScreen
├── models/
│   ├── word.dart                # Word(id, kanji?, reading, meaning, level), displayWord getter
│   └── study_record.dart        # StudyRecord(wordKey, correctCount, incorrectCount, lastStudied)
├── data/
│   ├── word_repository.dart     # WordRepository: getWordsByLevel, getWordCount, preloadAll, levels 상수
│   └── study_repository.dart    # StudyRepository: markCorrect(level, wordId), markIncorrect(level, wordId)
├── screens/
│   ├── pin_screen.dart
│   ├── home_screen.dart         # 현재: 레벨 카드 -> 모드 다이얼로그 (재구성 대상)
│   ├── flashcard_screen.dart    # FlashcardScreen({required this.level})
│   ├── quiz_screen.dart         # QuizScreen({required this.level})
│   ├── fill_blank_screen.dart   # FillBlankScreen({required this.level})
│   └── progress_screen.dart     # ProgressScreen()
```

### 기존 화면들의 공통 패턴 (반드시 따를 것)
```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../data/study_repository.dart';
import '../models/word.dart';

class XxxScreen extends StatefulWidget {
  final String level;
  const XxxScreen({super.key, required this.level});
  @override
  State<XxxScreen> createState() => _XxxScreenState();
}

class _XxxScreenState extends State<XxxScreen> {
  final WordRepository _wordRepo = WordRepository();
  final StudyRepository _studyRepo = StudyRepository();
  List<Word> _allWords = [];
  bool _isLoading = true;
  bool _isSessionComplete = false;
  // ... 모드별 상태 변수

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await _wordRepo.getWordsByLevel(widget.level);
    // ... 셔플, 세션 구성
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),  // 항상 이 배경색
      appBar: AppBar(
        title: Text('${widget.level} 모드명'),
        backgroundColor: const Color(0xFF모드색상),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF모드색상)))
          : _isSessionComplete
              ? _buildResultView()
              : _buildGameView(),
    );
  }
}
```

### 결과 화면 공통 패턴 (반드시 따를 것)
```dart
Widget _buildResultView() {
  return SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(아이콘, size: 80, color: Color(0xFF모드색상)),
            const SizedBox(height: 24),
            const Text('학습 완료!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 32),
            _buildStatRow(Icons.check_circle, '정답', '$_correctCount', Colors.green[600]!),
            // ... 기타 stat rows
            const SizedBox(height: 40),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('돌아가기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3949AB),
                  side: const BorderSide(color: Color(0xFF3949AB)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              const SizedBox(width: 16),
              Expanded(child: FilledButton.icon(
                onPressed: _restartSession,
                icon: const Icon(Icons.refresh),
                label: const Text('다시하기'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF모드색상),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
            ]),
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
    child: Row(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    ]),
  );
}
```

---

## Task 1: 홈 화면 재구성

**파일**: `lib/screens/home_screen.dart` (기존 파일 덮어쓰기)

**import 추가**:
```dart
import 'matching_screen.dart';
import 'listening_screen.dart';
import 'speed_ox_screen.dart';
```

**변경 내용**:
- 기존: JLPT 레벨 카드 5개 -> 탭 -> 모드 선택 다이얼로그
- 변경: 학습 모드 카드 6개 (2열 GridView) -> 탭 -> 레벨 선택 다이얼로그 (N5~N1)

**6가지 모드 카드 데이터** (순서대로):

| 모드명 | 아이콘 | 색상 | 화면 생성 |
|--------|--------|------|-----------|
| 플래시카드 | Icons.style_outlined | Color(0xFF5C6BC0) | FlashcardScreen(level: level) |
| 객관식 퀴즈 | Icons.quiz_outlined | Color(0xFF7E57C2) | QuizScreen(level: level) |
| 빈칸 채우기 | Icons.edit_note_outlined | Color(0xFF9575CD) | FillBlankScreen(level: level) |
| 매칭 게임 | Icons.grid_view_rounded | Color(0xFF26A69A) | MatchingScreen(level: level) |
| 리스닝 퀴즈 | Icons.headphones_rounded | Color(0xFFEF5350) | ListeningScreen(level: level) |
| 스피드 O/X | Icons.speed_rounded | Color(0xFFFF9800) | SpeedOxScreen(level: level) |

**레벨 선택 다이얼로그 구현**:
```dart
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
            Text('$modeName - 레벨 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 20),
            ...WordRepository.levels.map((level) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screenBuilder(level)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('JLPT $level', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            )),
          ],
        ),
      ),
    ),
  );
}
```

**모드 카드 레이아웃**: GridView.count(crossAxisCount: 2)
- 각 카드: Container 높이 120, 둥근 모서리(16), 그라데이션 배경(color + color.withValues(alpha: 0.7))
- 카드 내부: 아이콘(32) + SizedBox(8) + 모드명 Text(16, bold, white)
- InkWell로 탭 이벤트

**상단 타이틀**: '일본어 단어 연습' (기존과 동일)
**하단**: 진도 확인 버튼 유지 (기존 코드 그대로)

---

## Task 2: 매칭 게임 화면

**파일**: `lib/screens/matching_screen.dart` (신규 생성)

**색상 테마**: Color(0xFF26A69A)

### 전체 동작 흐름

1. initState -> _loadWords: 레벨에서 전체 단어 로드 -> 6개 랜덤 추출
2. 12개 타일 생성: 각 단어에서 {displayWord, word.id, isJapanese: true} + {meaning, word.id, isJapanese: false} -> 12개 셔플
3. Stopwatch 시작
4. 사용자가 타일 탭 -> _selectedIndices에 추가 (최대 2개)
5. 2개 선택되면 짝 체크:
   - 같은 word.id이고, 하나는 일본어/하나는 한국어 -> 정답
   - 그 외 -> 오답
6. 정답: _matchedIndices에 추가, markCorrect 호출
7. 오답: 빨간 테두리 0.5초 표시 후 선택 해제, _attempts++
8. 12개 전부 매칭되면 Stopwatch 중지, 결과 화면

### 타일 데이터 구조

```dart
class _Tile {
  final String text;       // displayWord 또는 meaning
  final int wordIndex;     // 원본 단어의 인덱스 (0~5)
  final bool isJapanese;   // 일본어 타일인지 한국어 타일인지

  _Tile({required this.text, required this.wordIndex, required this.isJapanese});
}
```

### 상태 변수

```dart
List<Word> _sessionWords = [];       // 6개 단어
List<_Tile> _tiles = [];             // 12개 타일 (셔플된)
Set<int> _selectedIndices = {};      // 현재 선택된 타일 인덱스 (최대 2)
Set<int> _matchedIndices = {};       // 맞춘 타일 인덱스
Set<int> _wrongIndices = {};         // 오답 표시 중인 타일 인덱스
int _attempts = 0;                   // 시도 횟수
bool _isChecking = false;            // 짝 체크 중 (추가 입력 방지)
final Stopwatch _stopwatch = Stopwatch();
String _elapsedDisplay = '0:00';     // 표시용 경과 시간
```

### UI 레이아웃

```
AppBar: "${widget.level} 매칭 게임" (backgroundColor: Color(0xFF26A69A))
─────────────────────────
경과 시간: 0:00    시도: 0
─────────────────────────
┌──────┐ ┌──────┐ ┌──────┐
│타일1  │ │타일2  │ │타일3  │
└──────┘ └──────┘ └──────┘
┌──────┐ ┌──────┐ ┌──────┐
│타일4  │ │타일5  │ │타일6  │
└──────┘ └──────┘ └──────┘
┌──────┐ ┌──────┐ ┌──────┐
│타일7  │ │타일8  │ │타일9  │
└──────┘ └──────┘ └──────┘
┌──────┐ ┌──────┐ ┌──────┐
│타일10 │ │타일11 │ │타일12 │
└──────┘ └──────┘ └──────┘
```

- GridView.count(crossAxisCount: 3, childAspectRatio: 1.3)
- padding: EdgeInsets.all(16), crossAxisSpacing: 10, mainAxisSpacing: 10

### 타일 스타일

```dart
// 기본 상태
Container(
  decoration: BoxDecoration(
    color: tile.isJapanese ? const Color(0xFFE8EAF6) : const Color(0xFFE0F2F1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey[300]!, width: 1.5),
  ),
)

// 선택 상태 (_selectedIndices에 포함)
border: Border.all(color: const Color(0xFF26A69A), width: 3)

// 오답 상태 (_wrongIndices에 포함)
border: Border.all(color: Colors.red, width: 3)

// 맞춘 상태 (_matchedIndices에 포함)
color: Colors.green[50], border: Border.all(color: Colors.green, width: 2)
// + 체크 아이콘 오버레이, 텍스트 Colors.green[700]

// 타일 텍스트
Text(tile.text, textAlign: TextAlign.center,
  style: TextStyle(fontSize: tile.isJapanese ? 18 : 14, fontWeight: FontWeight.w600))
```

### 경과 시간 업데이트

```dart
Timer.periodic(const Duration(seconds: 1), (timer) {
  if (_isSessionComplete) { timer.cancel(); return; }
  final seconds = _stopwatch.elapsed.inSeconds;
  setState(() => _elapsedDisplay = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}');
});
```

### 결과 화면 stat rows

- 경과 시간: _elapsedDisplay
- 시도 횟수: $_attempts

---

## Task 3: 리스닝 퀴즈 화면

**파일**: `lib/screens/listening_screen.dart` (신규 생성)

**색상 테마**: Color(0xFFEF5350)

### TTS 구현 (중요 - 반드시 이 방식으로)

flutter_tts 패키지를 사용하지 않는다. Web Speech API를 dart:js_interop으로 직접 호출한다.
별도 유틸 파일을 만든다.

**파일**: `lib/utils/tts_helper.dart` (신규 생성)

```dart
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void speakJapanese(String text) {
  web.window.speechSynthesis.cancel();
  final utterance = web.SpeechSynthesisUtterance(text);
  utterance.lang = 'ja-JP';
  utterance.rate = 0.85;
  web.window.speechSynthesis.speak(utterance);
}
```

pubspec.yaml에 이미 web 패키지가 있으므로 추가 의존성 불필요.
만약 web 패키지 import가 안 되면 dart:js_interop 방식으로:

```dart
import 'dart:js_interop';

@JS('SpeechSynthesisUtterance')
@staticInterop
class _SpeechSynthesisUtterance {
  external factory _SpeechSynthesisUtterance(String text);
}

extension on _SpeechSynthesisUtterance {
  external set lang(String value);
  external set rate(double value);
}

@JS('speechSynthesis.cancel')
external void _cancel();

@JS('speechSynthesis.speak')
external void _speak(_SpeechSynthesisUtterance utterance);

void speakJapanese(String text) {
  _cancel();
  final u = _SpeechSynthesisUtterance(text);
  u.lang = 'ja-JP';
  u.rate = 0.85;
  _speak(u);
}
```

두 방식 중 컴파일되는 것으로 사용. **flutter_tts 패키지는 절대 추가하지 말 것.**

### 전체 동작 흐름

1. _loadWords: 레벨 전체 단어 로드 -> 20개 랜덤 추출
2. 첫 문제 자동 재생: _speakCurrentWord() 호출
3. 사용자가 4지선다 중 선택
4. 정답/오답 피드백 + 일본어 텍스트 노출
5. 딜레이 후 다음 문제 + 자동 재생
6. 20문제 완료 시 결과 화면

### 상태 변수

```dart
List<Word> _allWords = [];
List<Word> _sessionWords = [];     // 20개
int _currentIndex = 0;
int _correctCount = 0;
int _incorrectCount = 0;
List<String> _choices = [];        // 4지선다
int _correctChoiceIndex = -1;
int? _selectedIndex;
bool _answered = false;
bool _showWord = false;            // 정답/오답 후 일본어 단어 표시 여부
```

### 4지선다 생성 (quiz_screen.dart와 동일 로직)

```dart
void _generateChoices() {
  final currentWord = _sessionWords[_currentIndex];
  final correctMeaning = currentWord.meaning;
  final wrongMeanings = _allWords
      .where((w) => w.meaning != correctMeaning)
      .map((w) => w.meaning)
      .toSet().toList()..shuffle(_random);
  final choices = <String>[correctMeaning];
  for (final m in wrongMeanings) {
    if (choices.length >= 4) break;
    choices.add(m);
  }
  while (choices.length < 4) choices.add('---');
  choices.shuffle(_random);
  setState(() {
    _choices = choices;
    _correctChoiceIndex = choices.indexOf(correctMeaning);
    _selectedIndex = null;
    _answered = false;
    _showWord = false;
  });
}
```

### UI 레이아웃

```
AppBar: "${widget.level} 리스닝 퀴즈" (backgroundColor: Color(0xFFEF5350))
─────────────────────────
진행률 바 + 정답/오답 카운터
─────────────────────────

        🔊 (크게, size: 80)
      [다시 듣기] 버튼

   (정답/오답 후에만 표시)
      일본어: 食べる
      읽기: たべる

─────────────────────────
┌─ A  선택지1 ─────────┐
└────────────────────────┘
┌─ B  선택지2 ─────────┐
└────────────────────────┘
┌─ C  선택지3 ─────────┐
└────────────────────────┘
┌─ D  선택지4 ─────────┐
└────────────────────────┘
```

- 스피커 아이콘: Icon(Icons.volume_up_rounded, size: 80, color: Color(0xFFEF5350))
- "다시 듣기" 버튼: TextButton.icon(icon: Icon(Icons.replay), label: Text('다시 듣기'))
- 4지선다 버튼: quiz_screen.dart의 _buildChoiceButton과 동일 스타일 (색상만 Color(0xFFEF5350) 계열로)
- 일본어 표시 영역: _showWord가 true일 때만 Column(단어 + 읽기) 표시

### 문제 전환 시

```dart
Future<void> _onChoiceSelected(int index) async {
  if (_answered) return;
  final word = _sessionWords[_currentIndex];
  final isCorrect = index == _correctChoiceIndex;

  setState(() { _selectedIndex = index; _answered = true; _showWord = true; });

  if (isCorrect) {
    await _studyRepo.markCorrect(widget.level, word.id);
    _correctCount++;
  } else {
    await _studyRepo.markIncorrect(widget.level, word.id);
    _incorrectCount++;
  }

  await Future.delayed(Duration(milliseconds: isCorrect ? 1500 : 2000));
  if (!mounted) return;

  if (_currentIndex + 1 >= _sessionWords.length) {
    setState(() => _isSessionComplete = true);
  } else {
    setState(() => _currentIndex++);
    _generateChoices();
    _speakCurrentWord();   // 다음 문제 자동 재생
  }
}
```

---

## Task 4: 스피드 O/X 퀴즈 화면

**파일**: `lib/screens/speed_ox_screen.dart` (신규 생성)

**색상 테마**: Color(0xFFFF9800)

### 전체 동작 흐름

1. _loadWords: 레벨 전체 단어 로드
2. _startGame: Timer.periodic 시작 (100ms 간격), 첫 문제 생성
3. _generateQuestion: 랜덤 단어 선택 + 50% 확률로 정답/오답 뜻 표시
4. 사용자가 O/X 버튼 탭 -> 판정 -> 피드백 -> 다음 문제
5. 60초 경과 시 타이머 중지, 결과 화면

### 상태 변수

```dart
List<Word> _allWords = [];
Word? _currentWord;
String _displayedMeaning = '';
bool _isCorrectPair = false;        // 현재 표시된 뜻이 맞는지
int _score = 0;
int _combo = 0;
int _maxCombo = 0;
int _correctCount = 0;
int _incorrectCount = 0;
int _remainingMs = 60000;           // 남은 시간 (밀리초)
Timer? _timer;
Color? _flashColor;                 // 정답/오답 피드백 색상 (null이면 표시 안 함)
bool _isGameOver = false;
```

### 문제 생성

```dart
void _generateQuestion() {
  final random = Random();
  _currentWord = _allWords[random.nextInt(_allWords.length)];
  _isCorrectPair = random.nextBool();

  if (_isCorrectPair) {
    _displayedMeaning = _currentWord!.meaning;
  } else {
    // 다른 단어의 뜻을 표시 (현재 단어와 다른 뜻)
    Word wrongWord;
    do {
      wrongWord = _allWords[random.nextInt(_allWords.length)];
    } while (wrongWord.meaning == _currentWord!.meaning);
    _displayedMeaning = wrongWord.meaning;
  }
  setState(() {});
}
```

### O/X 판정

```dart
void _onAnswer(bool userSaidCorrect) {
  if (_isGameOver) return;

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

  // 피드백 200ms 후 제거 + 다음 문제
  Future.delayed(const Duration(milliseconds: 200), () {
    if (!mounted || _isGameOver) return;
    setState(() => _flashColor = null);
    _generateQuestion();
  });
}
```

### 타이머

```dart
void _startGame() {
  _stopwatch 대신 Timer.periodic 사용:

  _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
    _remainingMs -= 100;
    if (_remainingMs <= 0) {
      _remainingMs = 0;
      _isGameOver = true;
      _isSessionComplete = true;
      timer.cancel();
    }
    setState(() {});
  });
  _generateQuestion();
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

### UI 레이아웃

```
AppBar: "${widget.level} 스피드 O/X" (backgroundColor: Color(0xFFFF9800))
─────────────────────────
타이머 바 (LinearProgressIndicator, value: _remainingMs / 60000)
점수: _score    콤보: 🔥 _combo
─────────────────────────

    ┌────────────────────┐
    │  日本語 (크게 48)    │
    │  よみがな (20)       │
    │                      │
    │  한국어 뜻 (크게 32)  │
    └────────────────────┘

    (콤보 5 이상일 때)
    🔥 5 Combo! +2점

─────────────────────────
┌──── O ────┐ ┌──── X ────┐
│   (초록)    │ │   (빨강)    │
│  Icons.    │ │  Icons.    │
│  circle    │ │  close     │
│  outlined  │ │  _rounded  │
└────────────┘ └────────────┘
```

- 타이머 바: LinearProgressIndicator(value: _remainingMs / 60000, backgroundColor: Color(0xFFFFE0B2), valueColor: AlwaysStoppedAnimation(Color(0xFFFF9800)))
- 카드: Container 흰색, borderRadius 24, boxShadow
- O/X 버튼: SizedBox(height: 80) 안에 Icon(size: 48) + Text
  - O: 초록 (Colors.green[600]), Icon: Icons.circle_outlined
  - X: 빨강 (Colors.red[600]), Icon: Icons.close_rounded
- 피드백: _flashColor != null일 때 Scaffold 전체에 AnimatedContainer로 테두리 색상 표시
  ```dart
  body: AnimatedContainer(
    duration: const Duration(milliseconds: 100),
    decoration: BoxDecoration(
      border: _flashColor != null ? Border.all(color: _flashColor!, width: 4) : null,
    ),
    child: ... // 게임 UI
  )
  ```

### 결과 화면 stat rows

- 최종 점수: $_score (Icons.star)
- 정답: $_correctCount (Icons.check_circle)
- 오답: $_incorrectCount (Icons.cancel)
- 최대 콤보: $_maxCombo (Icons.local_fire_department)

---

## 공통 규칙 (서브에이전트 필독)

1. **배경색**: 모든 Scaffold의 backgroundColor는 `const Color(0xFFF5F0FF)`
2. **AppBar 스타일**: foregroundColor: Colors.white, elevation: 0
3. **UI 텍스트**: 전부 한국어 (영어 사용 금지)
4. **flutter_tts 패키지 추가 금지**: TTS는 `lib/utils/tts_helper.dart`로 직접 구현
5. **pubspec.yaml 수정 금지**: 기존 의존성만 사용
6. **import 경로**: 상대 경로 사용 (`../data/word_repository.dart` 등)
7. **dart:html 사용 금지**: `package:web/web.dart` 또는 `dart:js_interop` 사용
8. **withOpacity() 사용 금지**: `withValues(alpha: 0.5)` 사용
9. **결과 화면**: '학습 완료!' 제목, '돌아가기'/'다시하기' 버튼, _buildStatRow 헬퍼
10. **모든 화면은 SafeArea로 감쌀 것**
