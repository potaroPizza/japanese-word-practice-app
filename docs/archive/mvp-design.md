# 일본어 단어 연습 앱 - MVP 설계서

## 앱 구조

```
lib/
├── main.dart                  # 앱 진입점
├── models/                    # 데이터 모델
│   ├── word.dart              # 단어 모델
│   └── study_record.dart      # 학습 기록 모델
├── data/                      # 데이터 레이어
│   ├── word_repository.dart   # 단어 데이터 접근
│   └── study_repository.dart  # 학습 기록 접근
├── screens/                   # 화면
│   ├── home_screen.dart       # 홈 (레벨 선택)
│   ├── flashcard_screen.dart  # 플래시카드
│   ├── quiz_screen.dart       # 객관식 퀴즈
│   ├── fill_blank_screen.dart # 빈칸 채우기
│   └── progress_screen.dart   # 진도 확인
├── widgets/                   # 재사용 위젯
│   ├── flashcard_widget.dart  # 플래시카드 카드
│   ├── quiz_option.dart       # 퀴즈 선택지
│   └── progress_bar.dart      # 진도 바
└── assets/                    # 단어 데이터 (JSON)
    └── words/
        ├── n5.json
        ├── n4.json
        ├── n3.json
        ├── n2.json
        └── n1.json
```

## 데이터 모델

### Word (단어)

| 필드 | 타입 | 설명 |
|------|------|------|
| id | int | 고유 ID |
| kanji | String | 한자 표기 (없으면 null) |
| reading | String | 히라가나/카타카나 읽기 |
| meaning | String | 한국어 뜻 |
| level | String | JLPT 레벨 (N5~N1) |

### StudyRecord (학습 기록)

| 필드 | 타입 | 설명 |
|------|------|------|
| wordId | int | 단어 ID |
| correctCount | int | 맞힌 횟수 |
| incorrectCount | int | 틀린 횟수 |
| lastStudied | DateTime | 마지막 학습 일시 |

## 화면 흐름

```
홈 화면 (JLPT 레벨 선택)
  ├── 플래시카드 모드
  ├── 객관식 퀴즈 모드
  ├── 빈칸 채우기 모드
  └── 진도 확인
```

### 홈 화면

- JLPT N5~N1 레벨 선택
- 학습 모드 선택 (플래시카드 / 객관식 / 빈칸채우기)
- 각 레벨별 학습 진도 요약 표시

### 플래시카드 화면

- 카드 탭 -> 뒤집기 애니메이션으로 뜻 표시
- 좌우 스와이프로 "알고 있음" / "모름" 분류
- 상단에 진행률 표시

### 객관식 퀴즈 화면

- 일본어 단어 제시 + 4지선다 한국어 뜻
- 정답 선택 시 초록색, 오답 시 빨간색 피드백
- 연속 정답 수 표시

### 빈칸 채우기 화면

- 한국어 뜻 제시 -> 일본어(히라가나) 직접 입력
- 정답 확인 후 피드백
- 힌트 기능 (첫 글자 보여주기)

### 진도 확인 화면

- 레벨별 학습 완료율
- 틀린 단어 목록
- "틀린 단어 복습" 바로가기

## 로컬 저장소

- 브라우저 localStorage 또는 IndexedDB 사용 (shared_preferences 패키지 등)
- 학습 기록을 브라우저에 저장
- 단어 데이터는 JSON 파일로 앱에 내장 (assets)

## 배포

- Flutter Web 빌드 (`flutter build web`)
- GitHub Pages로 배포 (git push 시 자동 배포)
- GitHub Actions로 CI/CD 구성 (push -> 빌드 -> gh-pages 브랜치에 배포)
- 접속 URL: `https://{username}.github.io/{repo-name}/`
- 누나에게 URL 링크 공유 -> iPhone Safari에서 바로 사용
