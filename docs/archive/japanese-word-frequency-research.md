# 일본어 고빈도 단어 학술 연구 조사

## 1. 핵심 수치 요약: 단어 수별 텍스트 커버율

출처: 沖森卓也 외, 『図解日本語』, 三省堂, 2006, p.82

| 어휘 수 | 일본어 | 영어 | 프랑스어 | 중국어 |
|---------|--------|------|----------|--------|
| 100어 | - | - | - | - |
| 1,000어 | **60.5%** | 80.5% | 83.5% | 73.0% |
| 2,000어 | **70.0%** | 86.6% | 89.4% | - |
| 3,000어 | **75.3%** | 90.0% | 92.2% | - |
| 5,000어 | **81.7%** | 93.5% | 96.0% | - |
| 10,000어 | **91.7%** | - | - | - |

**핵심 인사이트**: 일본어는 동일 어휘 수 대비 커버율이 영어/프랑스어보다 현저히 낮다. 영어는 5,000어로 93.5%를 달성하지만, 일본어는 동일 수준(90%+)에 도달하려면 약 10,000어가 필요하다.

### 미디어별 커버율 (Hatakeyama, CAJLE 2022)

| 미디어 | 1,000어 | 98% 도달 필요 어휘 |
|--------|---------|-------------------|
| 소설 (容疑者Xの献身) | 84.87% | ~11,000어 |
| 애니메이션 (토토로) | 90.72% | ~10,000어 |
| 애니메이션 (센과 치히로) | - | ~12,000어 |

---

## 2. 주요 코퍼스 및 빈도 연구

### 2.1 BCCWJ (現代日本語書き言葉均衡コーパス)

- **기관**: 国立国語研究所 (NINJAL, National Institute for Japanese Language and Linguistics)
- **규모**: 약 1억 430만어 (104.3 million words)
- **장르**: 서적, 잡지, 신문, 정부 백서, 블로그, 인터넷 게시판, 교과서, 법률문서 등
- **특징**: 일본 최초의 균형 코퍼스(balanced corpus). 무작위 샘플링 기법을 사용하여 대표성 극대화
- **어휘표 규모**: 단단위(短単位) 어휘표 약 18만어, 장단위(長単位) 어휘표 약 243만어
- **공개 데이터**:
  - 단단위(Short Unit) 어휘 빈도표
  - 장단위(Long Unit) 어휘 빈도표
  - 품사 구성표, 어종 구성표
- **접근**: 연구/교육 목적 무료 공개
- **URL**: https://clrd.ninjal.ac.jp/bccwj/en/freq-list.html
- **학술 논문**: Maekawa, K. (2013). "Balanced corpus of contemporary written Japanese." *Language Resources and Evaluation*, Springer.

### 2.2 A Frequency Dictionary of Japanese (Routledge)

- **저자**: Tono Yukio (投野由紀夫), Yamazaki Makoto (山崎誠), Maekawa Kikuo (前川喜久雄)
- **출판**: Routledge, 2013 (ISBN: 978-0415610131)
- **코퍼스**: BCCWJ 기반 1억어 코퍼스 (spoken, fiction, non-fiction, news)
- **수록 어휘**: 상위 5,000어
- **데이터 구조**:
  - 빈도 (Freq. per million): 백만어당 출현 횟수
  - 분산도 (Dispersion): 0~1 사이 값. 텍스트 전반에 걸친 균등 분포 정도
  - 레지스터별 상위 50어: BK(서적), WB(웹), OF(공문서), NM(신문잡지), SP(구어)
- **25개 주제별 빈도 목록**: 음식, 날씨, 직업, 여가 등
- **데이터 접근**: GitHub Gist에 5,000어 전체 TSV 데이터 공개 (https://gist.github.com/fasiha/1340015b28163c607278cf7d93c0a7ea)

### 2.3 Google Japanese N-Gram Corpus

- **수집**: Google Japan, 2007년
- **규모**: 200억 문장 이상 분석, 약 250만 고유 1-gram
- **방법론**: 일본어 웹페이지 크롤링 -> MeCab + IPADIC 형태소 분석
- **필터링**: 히라가나 5% 이상, 일본어 문자 70% 이상인 문장만 포함
- **제한**: 20회 이상 출현한 n-gram만 포함, 2007년 데이터로 신조어 미반영
- **URL**: https://www.edrdg.org/~jwb/paperdir/JGNGWordFreq.html

### 2.4 Leeds University Internet Corpus

- **기관**: University of Leeds, Centre for Translation Studies
- **규모**: 15,000어 빈도 목록
- **기반**: 인터넷 텍스트 코퍼스
- **접근**: https://www.manythings.org/japanese/words/leeds/
- **GitHub**: 44,998어 확장 버전 (https://github.com/hingston/japanese)

### 2.5 Tsukuba Web Corpus (筑波ウェブコーパス)

- **규모**: 약 11억어 (1.1 billion words)
- **수집원**: 일본어 웹사이트
- **검색 도구**: NINJAL-LWP (NLT)
- **URL**: https://tsukubawebcorpus.jp/en/

### 2.6 OpenSubtitles 기반 빈도 목록

- **출처**: OpenSubtitles2018 코퍼스
- **제작**: hermitdave/FrequencyWords (GitHub)
- **특징**: 영화/드라마 자막 기반 구어체 빈도 데이터
- **주의**: 일본어 자막의 4%만 원본 언어 메타데이터가 일치 (번역 자막 혼입 가능성)
- **URL**: https://github.com/hermitdave/FrequencyWords

### 2.7 일본어 자막 빈도 목록 (Drama/Anime/Film)

- **제작**: chriskempson (GitHub)
- **데이터**: 12,277개 자막 파일 분석
- **도구**: JParser, cb's Japanese Text Analysis Tool
- **출력**: word_freq_report.txt (빈도, 단어, 순위, 누적 백분율, 품사)
- **URL**: https://github.com/chriskempson/japanese-subtitles-word-kanji-frequency-lists

---

## 3. 학술 연구 및 논문

### 3.1 Sato Satoshi (2014) - 텍스트 가독성과 단어 분포

- **논문**: "Text Readability and Word Distribution in Japanese"
- **학회**: LREC 2014 (Reykjavik, Iceland), pp. 2811-2815
- **URL**: https://aclanthology.org/L14-1505/
- **핵심 발견**:
  1. 일본어는 영어 대비 고빈도어가 토큰에서 차지하는 비율이 낮다
  2. 난이도별 type-coverage curve가 예상과 다른 형태를 보인다
  3. 쉬운 텍스트의 고빈도어와 어려운 텍스트의 고빈도어 간 교집합이 예상보다 작다
- **의미**: 일본어는 텍스트 난이도에 따라 사용되는 어휘가 크게 달라지므로, 단순한 빈도순 학습만으로는 한계가 있다

### 3.2 Honda Yukari (2019) - 읽기 기본 어휘 1만어 선정

- **논문**: 「コーパスに基づく「読解基本語彙1万語」の選定」
- **저널**: 日本語教育, Vol. 172, 2019
- **소속**: 東京外国語大学 (Tokyo University of Foreign Studies)
- **URL**: https://www.jstage.jst.go.jp/article/nihongokyoiku/172/0/172_118/_article/-char/ja/
- **방법론**: 코퍼스 기반 빈도 + 분산도 + 복수 통계 지표로 중요도 정량화 -> 순위 매김
- **핵심 발견**: 「読解基本語彙1万語」가 JLPT 「出題基準」보다 높은 커버율을 보임

### 3.3 Hatakeyama Mamoru (2022) - 소설/애니메이션 이해에 필요한 어휘력

- **논문**: 「小説やアニメを日本語で理解するために、どの程度の語彙力が必要になるのか」
- **학회**: CAJLE 2022 Proceedings (Canadian Association of Japanese Language Education)
- **URL**: https://www.cajle.ca/wp-content/uploads/2022/11/Final_05_CAJLE2022Proceedings_HatakeyamaMamoruJP.pdf
- **핵심 데이터**:
  - 소설 (容疑者Xの献身): 상위 1,000어 = 84.87%, 2,000어 = ~90%, 98% 도달 = ~11,000어
  - 애니메이션 (토토로): 상위 1,000어 = 90.72%, 98% 도달 = ~10,000어
  - 애니메이션 (센과 치히로의 행방불명): 98% 도달 = ~12,000어

### 3.4 Matsushita Tatsuhiko (松下達彦) - 일본어 교육 어휘 데이터베이스

- **소속**: 東京大学 (현재) / 元 名古屋大学
- **데이터**: 서적 약 2,800만어 + Yahoo知恵袋 약 500만어 기반
- **어휘 수**: 141,950어
- **일본어 학술 공통어 목록**: 2,591어 (9단계, Level 0~VIII)
- **특징**: 10개 하위 장르의 빈도에서 분산도를 계산하고, 총 사용 빈도를 곱한 "중요도 계수"로 순위 매김
- **URL**: http://www17408ui.sakura.ne.jp/tatsum/list.html

### 3.5 Nation, I.S.P. (2006) - 읽기와 듣기에 필요한 어휘 크기 (일반 언어학)

- **논문**: "How Large a Vocabulary is Needed For Reading and Listening?"
- **핵심 이론**:
  - 독해를 위한 적절한 이해: 텍스트 어휘의 **95%** 이상 인지 필요 (Laufer, 1989)
  - 보조 없는 이해: 텍스트 어휘의 **98%** 인지 필요 (Hu & Nation, 2000)
  - 영어 기준: 98% 커버 = 8,000~9,000 word family, 구어 = 6,000~7,000 word family
- **일본어 적용**: 일본어의 낮은 커버율 특성상, 동일 수준 달성에 훨씬 더 많은 어휘 필요

### 3.6 Zipf 법칙과 일본어의 특수성

- **관련 연구**: "Zipf's law in phonograms and Weibull distribution in ideograms" (Academia.edu)
- **핵심**: 일본어는 표준 Zipf 법칙을 따르지 않음
  - 표음문자(히라가나/가타카나): Zipf 법칙에 가까운 멱법칙 분포
  - 표의문자(한자): 확장 지수 함수(Weibull distribution) 분포
  - 문자 빈도 분포가 3단계로 변화: 선형 증가 -> 로그 증가 -> 포화
- **의미**: 일본어 어휘 학습은 다른 언어와 다른 전략이 필요하며, 단순 빈도순 접근의 효과가 상대적으로 낮다

---

## 4. JLPT 레벨과 빈도 분석

JLPT 공식 기관(日本国際教育支援協会/国際交流基金)은 공식 어휘 목록을 발표하지 않지만, 커뮤니티와 연구에서 추정한 레벨별 어휘 수는 다음과 같다.

| JLPT 레벨 | 추정 어휘 수 (누적) | 한자 수 (누적) | 예상 커버율 |
|-----------|-------------------|-------------|-----------|
| N5 | ~800 | ~100 | ~50% |
| N4 | ~1,500 | ~170 (+ ~70) | ~60% |
| N3 | ~3,750 | ~650 (+ ~370) | ~75% |
| N2 | ~6,000 | ~1,000 (+ ~350) | ~82-85% |
| N1 | ~10,000 | ~2,136 (常用漢字 전체) | ~90-92% |

---

## 5. 실제 단어 목록 확보 가능 출처

| 출처 | 단어 수 | 형태 | 접근 방법 |
|------|---------|------|----------|
| BCCWJ 어휘표 | ~180,000 (단단위) | TSV/CSV | https://clrd.ninjal.ac.jp/bccwj/en/freq-list.html (무료 다운로드) |
| Routledge 5000 (Tono) | 5,000 | TSV | GitHub Gist (https://gist.github.com/fasiha/1340015b28163c607278cf7d93c0a7ea) |
| Leeds Internet Corpus | 15,000~44,998 | TXT | https://github.com/hingston/japanese |
| Wiktionary 빈도 목록 | 20,000 | Wiki | https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists/Japanese |
| OpenSubtitles 빈도 | 50,000+ | TXT | https://github.com/hermitdave/FrequencyWords |
| 일본어 자막 빈도 | 12,277 파일 기반 | TXT | https://github.com/chriskempson/japanese-subtitles-word-kanji-frequency-lists |
| iKnow! Core 6000 | 6,000 | 웹 | https://iknow.jp/content/japanese |
| Kanshudo Routledge | 4,909 (중복 제외) | 웹 | https://www.kanshudo.com/collections/routledge |
| 松下 교육 어휘표 | 141,950 | DB | http://www17408ui.sakura.ne.jp/tatsum/list.html |

---

## 6. 앱 적용 시사점

### 6.1 목표 어휘 수 설계

연구 결과를 종합하면:

- **1,000어**: 일상 텍스트의 ~60% 커버. 구어체(애니/드라마)에서는 ~90% 가능
- **3,000어**: ~75% 커버. 일상 대화 기본 수준
- **5,000어**: ~82% 커버. 기본적 독해 가능 수준
- **10,000어**: ~92% 커버. 자유로운 독해 수준 (JLPT N1 상당)

**권장**: 앱의 핵심 목표를 **상위 5,000어 마스터** (82% 커버)로 설정하되, 10,000어까지 확장 가능하도록 설계

### 6.2 어휘 정렬 전략

Sato(2014)의 연구에서 밝혀진 바와 같이, 쉬운 텍스트와 어려운 텍스트의 고빈도어 교집합이 작다. 따라서:

- **단순 빈도순 나열보다 분산도(dispersion)를 함께 고려**해야 한다
- Tono의 Routledge 사전처럼 빈도 x 분산도 조합 순위가 더 효과적
- 텍스트 유형(구어/문어/뉴스/웹)별 빈도를 구분하여 학습 목적에 맞게 제공

### 6.3 데이터 소스 권장

1. **1순위: Routledge/Tono 5,000어** - 학술적으로 가장 검증됨. BCCWJ 기반. GitHub에서 TSV 확보 가능
2. **2순위: BCCWJ 공식 어휘표** - 가장 방대. 연구/교육 목적 무료. 다만 원시 데이터 정제 필요
3. **보조: 자막 기반 빈도 목록** - 구어체/일상 회화 패턴 반영. 드라마/애니 학습자에게 유용
4. **JLPT 레벨 태깅**: 각 단어에 JLPT 레벨을 매핑하여 학습 단계별 필터링 가능하도록

### 6.4 일본어 특수성 반영

- 일본어는 Zipf 법칙을 따르지 않으므로, 영어권 앱의 단순 빈도순 접근 방식을 그대로 적용하면 비효율적
- **레지스터(구어/문어/뉴스 등) 구분이 중요**: 같은 고빈도어라도 구어에서만 자주 쓰이는 단어(예: えー)와 범용적인 단어(예: こと)는 분산도가 크게 다름
- **한자/읽기 변형 고려**: 동일 단어라도 한자 표기와 히라가나 표기가 다를 수 있으므로 형태소 수준의 처리 필요

---

## 참고문헌

1. 沖森卓也, 木村義之, 陳力衛, 山本真吾 (2006). 『図解日本語』. 三省堂, p.82.
2. Tono, Y., Yamazaki, M., & Maekawa, K. (2013). *A Frequency Dictionary of Japanese*. Routledge.
3. Maekawa, K. (2013). "Balanced corpus of contemporary written Japanese." *Language Resources and Evaluation*, Springer.
4. Sato, S. (2014). "Text Readability and Word Distribution in Japanese." *Proceedings of LREC 2014*, pp. 2811-2815.
5. Honda, Y. (2019). 「コーパスに基づく「読解基本語彙1万語」の選定」. 『日本語教育』, Vol. 172.
6. Hatakeyama, M. (2022). 「小説やアニメを日本語で理解するために、どの程度の語彙力が必要になるのか」. *CAJLE 2022 Proceedings*.
7. Nation, I.S.P. (2006). "How Large a Vocabulary is Needed For Reading and Listening?" *The Canadian Modern Language Review*.
8. Schmitt, N., Jiang, X., & Grabe, W. (2011). "The Percentage of Words Known in a Text and Reading Comprehension." *The Modern Language Journal*.
9. 松下達彦. 日本語教育語彙表. http://www17408ui.sakura.ne.jp/tatsum/list.html
