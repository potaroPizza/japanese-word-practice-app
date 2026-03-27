# Flutter Web 무료 호스팅 옵션 비교

> 조사일: 2026-03-27

## 공통 사전 준비

모든 서비스에 배포하기 전, Flutter Web 빌드가 필요합니다.

```bash
# 기본 빌드 (루트 경로에 배포할 경우)
flutter build web --release

# 하위 경로에 배포할 경우 (예: GitHub Pages의 /repo-name/)
flutter build web --release --base-href /repo-name/
```

빌드 결과물은 `build/web/` 디렉토리에 생성됩니다.

---

## 1. GitHub Pages

### 무료 티어 제한

| 항목 | 제한 |
|------|------|
| 저장 용량 | 1 GB (사이트 크기) |
| 대역폭 | 100 GB/월 (소프트 리밋) |
| 빌드 횟수 | 10회/시간 (GitHub Actions 사용 시 미적용) |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (Let's Encrypt 자동 발급) |

### 배포 방법

**방법 A: 수동 배포 (gh-pages 브랜치)**

```bash
# 1. 빌드
flutter build web --release --base-href /repository-name/

# 2. gh-pages 브랜치에 배포 (peanut 패키지 사용)
dart pub global activate peanut
peanut --directory build/web

# 3. 푸시
git push origin gh-pages
```

**방법 B: GitHub Actions 자동 배포 (권장)**

`.github/workflows/deploy.yml` 파일 생성:

```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter build web --release --base-href /${{ github.event.repository.name }}/
      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

리포지토리 Settings > Pages > Source를 "GitHub Actions"로 설정합니다.

### 장단점

- **장점**: 완전 무료, GitHub 연동 자연스러움, Actions로 CI/CD 자동화 용이, Let's Encrypt HTTPS 자동 적용
- **단점**: 정적 사이트만 가능, `--base-href` 설정 필요 (서브 경로 배포 시), 빌드 시간 제한 있음, 공개 저장소 필요 (무료 플랜)

---

## 2. Firebase Hosting

### 무료 티어 제한

| 항목 | 제한 |
|------|------|
| 저장 용량 | 10 GB |
| 대역폭 | 360 MB/일 (약 10.8 GB/월) |
| 개별 파일 크기 | 2 GB |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (자동 SSL) |
| CDN | 글로벌 CDN 무료 제공 |

### 배포 방법

```bash
# 1. Firebase CLI 설치
npm install -g firebase-tools

# 2. 로그인
firebase login

# 3. 프로젝트 초기화
firebase init hosting
# - public 디렉토리: build/web
# - SPA 설정: Yes
# - GitHub Actions 자동 배포: 선택

# 4. Flutter 빌드
flutter build web --release

# 5. 배포
firebase deploy --only hosting
```

### 장단점

- **장점**: 글로벌 CDN 무료, Flutter와 같은 Google 생태계, Firestore/Auth 등 백엔드 서비스 통합 용이, 롤백 기능
- **단점**: 일일 대역폭 제한이 낮음 (360 MB/일), Google 계정 필요, Firebase 프로젝트 설정 필요, 10 GB 초과 시 배포 불가 (Blaze 플랜 업그레이드 필요)

---

## 3. Vercel

### 무료 티어 제한 (Hobby Plan)

| 항목 | 제한 |
|------|------|
| 대역폭 | 100 GB/월 |
| 빌드 횟수 | 무제한 프로젝트 |
| Serverless 함수 | 150,000 호출/월 |
| Edge 요청 | 1,000,000/월 |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (자동 SSL) |

**주의**: Hobby 플랜은 개인/비상업적 용도로만 사용 가능합니다.

### 배포 방법

**방법 A: Git 연동 (권장)**

1. GitHub에 코드 푸시
2. [vercel.com](https://vercel.com)에서 Import Project
3. 빌드 설정:
   - Framework Preset: `Other`
   - Install Command: `if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && flutter/bin/flutter doctor && flutter/bin/flutter config --enable-web`
   - Build Command: `flutter/bin/flutter build web --release`
   - Output Directory: `build/web`

**방법 B: 로컬 빌드 후 수동 배포**

```bash
# 1. Vercel CLI 설치
npm install -g vercel

# 2. Flutter 빌드
flutter build web --release

# 3. 배포
cd build/web
vercel --prod
```

### 장단점

- **장점**: 대역폭 넉넉 (100 GB/월), Git 푸시마다 프리뷰 URL 자동 생성, 빠른 글로벌 CDN, 간편한 롤백
- **단점**: 상업적 용도 불가 (무료 플랜), Flutter 공식 지원 아님 (빌드 설정 수동 필요), 빌드 시 Flutter SDK 클론으로 빌드 시간이 김

---

## 4. Netlify

### 무료 티어 제한

**신규 가입 (2025년 9월 이후 - 크레딧 기반)**

| 항목 | 제한 |
|------|------|
| 크레딧 | 300 크레딧/월 |
| 프로덕션 배포 | 약 20회/월 (배포당 15 크레딧) |
| CDN | 글로벌 CDN 포함 |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (Let's Encrypt) |

**기존 계정 (레거시 플랜)**

| 항목 | 제한 |
|------|------|
| 대역폭 | 100 GB/월 |
| 빌드 시간 | 300분/월 |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (Let's Encrypt) |

### 배포 방법

**방법 A: 드래그 앤 드롭 (가장 간단)**

1. `flutter build web --release` 실행
2. [app.netlify.com](https://app.netlify.com)에서 "Add new site" > "Deploy manually"
3. `build/web` 폴더를 드래그 앤 드롭

**방법 B: Netlify CLI**

```bash
# 1. CLI 설치
npm install -g netlify-cli

# 2. Flutter 빌드
flutter build web --release

# 3. 배포
netlify deploy --dir=build/web --prod
```

**방법 C: Git 연동 (CI/CD)**

1. GitHub 연결 후 빌드 설정:
   - Build command: `flutter/bin/flutter build web --release`
   - Publish directory: `build/web`
2. Flutter SDK Build Plugin 활성화

### 장단점

- **장점**: 드래그 앤 드롭 배포 가능 (가장 간편), 프리뷰 배포 지원, 폼 핸들링/서버리스 함수 제공
- **단점**: 2025년 9월 이후 크레딧 기반 과금으로 무료 티어 대폭 축소 (월 약 20회 배포), Flutter 공식 지원 아님

---

## 5. Cloudflare Pages

### 무료 티어 제한

| 항목 | 제한 |
|------|------|
| 사이트 수 | 무제한 |
| 대역폭 | 무제한 |
| 요청 수 | 무제한 |
| 빌드 횟수 | 500회/월 |
| 동시 빌드 | 1개 |
| 커스텀 도메인 | 100개/프로젝트 |
| HTTPS | 지원 (자동 SSL) |
| 상업적 사용 | 허용 |

### 배포 방법

**방법 A: Git 연동**

1. [dash.cloudflare.com](https://dash.cloudflare.com) > Workers & Pages > Create
2. GitHub/GitLab 연결 후 리포지토리 선택
3. 빌드 설정:
   - Framework preset: `None`
   - Build command: (비워두거나 Flutter 빌드 명령어)
   - Build output directory: `build/web`

**방법 B: 로컬 빌드 후 수동 업로드**

```bash
# 1. Flutter 빌드
flutter build web --release

# 2. Wrangler CLI 사용
npm install -g wrangler
wrangler pages deploy build/web --project-name=my-flutter-app
```

**방법 C: 대시보드에서 직접 업로드**

1. Cloudflare 대시보드 > Workers & Pages > Create
2. "Upload assets" 선택
3. `build/web` 폴더 업로드

### 장단점

- **장점**: 대역폭/요청 무제한 (무료 호스팅 중 가장 관대), 상업적 사용 허용, 글로벌 CDN, 빠른 응답 속도
- **단점**: 빌드 500회/월 제한 (로컬 빌드 후 업로드 시 무관), 동시 빌드 1개, Cloudflare 생태계 학습 필요

---

## 6. 기타 무료 정적 호스팅

### Surge.sh

| 항목 | 내용 |
|------|------|
| 가격 | 무료 (Pro: $30/월) |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | surge.sh 서브도메인만 무료 SSL, 커스텀 도메인 SSL은 유료 ($30/월) |
| 저장 용량/대역폭 | 명시적 제한 없음 |

```bash
# 배포
npm install -g surge
flutter build web --release
cd build/web
surge
```

- **장점**: CLI 한 줄로 배포 가능 (가장 빠른 배포), 무제한 프로젝트, 무제한 커스텀 도메인
- **단점**: 커스텀 도메인 HTTPS 유료, CI/CD 연동 미흡, 커뮤니티 작음

### Render

| 항목 | 내용 |
|------|------|
| 가격 | 정적 사이트 무료 |
| 대역폭 | 100 GB/월 |
| 빌드 시간 | 750분/월 |
| 커스텀 도메인 | 지원 (무료) |
| HTTPS | 지원 (자동 SSL) |

- **장점**: 정적 사이트 영구 무료, GitHub 연동 자동 배포, 깔끔한 UI
- **단점**: 빌드 시간 제한 있음, Flutter 공식 지원 아님

---

## 종합 비교표

| 서비스 | 대역폭 | 저장 용량 | HTTPS | 커스텀 도메인 | 상업적 사용 | 배포 난이도 |
|--------|---------|-----------|-------|---------------|-------------|-------------|
| **GitHub Pages** | 100 GB/월 | 1 GB | O | O | O | 중 |
| **Firebase Hosting** | 360 MB/일 | 10 GB | O | O | O | 중 |
| **Vercel** | 100 GB/월 | - | O | O | X (무료) | 중 |
| **Netlify** | 크레딧 기반 | - | O | O | O | 하 |
| **Cloudflare Pages** | 무제한 | - | O | O | O | 중 |
| **Surge.sh** | 미공개 | 미공개 | 서브도메인만 | O | O | 하 |
| **Render** | 100 GB/월 | - | O | O | O | 중 |

## 추천

### 개인 프로젝트 / 포트폴리오

**1순위: Cloudflare Pages** - 대역폭 무제한, 상업적 사용 가능, 빠른 CDN
**2순위: GitHub Pages** - 가장 익숙한 플랫폼, GitHub Actions CI/CD 연동 편리

### 빠른 프로토타입 / 데모

**1순위: Surge.sh** - CLI 한 줄로 즉시 배포
**2순위: Netlify** - 드래그 앤 드롭 배포

### Firebase 백엔드 연동 프로젝트

**Firebase Hosting** - Firestore, Auth 등과 자연스러운 통합

### 트래픽이 많은 프로젝트

**Cloudflare Pages** - 유일하게 대역폭 무제한

---

## 출처

- [GitHub Pages Limits - GitHub Docs](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)
- [Firebase Hosting Usage Quotas & Pricing](https://firebase.google.com/docs/hosting/usage-quotas-pricing)
- [Firebase Pricing](https://firebase.google.com/pricing)
- [Vercel Limits](https://vercel.com/docs/limits)
- [Vercel Free Tier - freetiers.com](https://www.freetiers.com/directory/vercel)
- [Netlify Credit-Based Pricing Plans](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/credit-based-pricing-plans/)
- [Cloudflare Pages Limits](https://developers.cloudflare.com/pages/platform/limits/)
- [Cloudflare Pages Pricing](https://www.cloudflare.com/plans/developer-platform/)
- [Surge.sh Pricing](https://surge.sh/pricing)
- [Surge.sh SSL](https://surge.sh/help/securing-your-custom-domain-with-ssl)
- [Render Deploy for Free](https://render.com/docs/free)
- [Flutter Web Build & Deploy](https://docs.flutter.dev/deployment/web)
- [Flutter Web on GitHub Pages - Code With Andrea](https://codewithandrea.com/articles/flutter-web-github-pages/)
- [Deploy Flutter Web to Vercel - DEV Community](https://dev.to/davidongora/deploy-flutter-web-app-to-vercel-49pp)
- [Deploy Flutter Web on Netlify - GeeksforGeeks](https://www.geeksforgeeks.org/flutter/how-to-deploy-flutter-web-app-on-netlify/)
- [Deploy Flutter Web to Cloudflare Pages - DEV Community](https://dev.to/hrishiksh/deploy-flutter-web-app-to-cloudflare-pages-jcl)
