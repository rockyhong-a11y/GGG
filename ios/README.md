# GGG iOS 래퍼 앱

배포된 웹앱(https://rockyhong-a11y.github.io/GGG/)을 WKWebView 로 감싼 네이티브 iOS 앱입니다.

**만든 이유**: iOS 사파리·크롬·홈화면 웹앱은 전부 동일한 WebKit이라 웹에서 코드로
발생시키는 진동(햅틱)이 차단됩니다(실기기 확인). 이 래퍼는 웹의 `haptic()` 호출을
네이티브 브리지로 받아 **UIKit 피드백 제너레이터(진짜 Taptic Engine)** 를 울리므로
리스트 드래그 '드르륵'이 확실하게 동작합니다.

- 웹이 업데이트되면 **앱 재설치 없이 자동 반영**됩니다 (앱은 웹을 로드만 함)
- 햅틱 매핑: `light` → SelectionFeedback(휠 피커 틱), `medium` → Impact(.medium), `strong` → Impact(.heavy)
- 외부 링크(인벤/루리웹 원문, 유튜브)는 사파리로 열립니다

## 빌드 & 설치 (Mac + Xcode 15 이상 필요)

무료 Apple ID로도 본인 기기에 설치할 수 있습니다(7일마다 재서명 필요).
유료 개발자 계정이면 1년 서명 + TestFlight 배포 가능.

### 방법 A — XcodeGen (권장)

```bash
brew install xcodegen
cd ios
xcodegen            # GGG.xcodeproj 생성
open GGG.xcodeproj
```

### 방법 B — Xcode 에서 수동 생성

1. Xcode → **File > New > Project… > iOS > App**
   - Product Name: `GGG` / Interface: **SwiftUI** / Language: **Swift**
2. 템플릿이 만든 `GGGApp.swift`·`ContentView.swift` 를 지우고,
   이 폴더의 `GGG/GGGApp.swift` 와 `GGG/WebView.swift` 두 파일을 프로젝트에 추가
3. (선택) TARGETS > GGG > Info 에서 Supported interface orientations 를 Portrait 만 남김

### 공통 — 서명 & 실행

1. TARGETS > GGG > **Signing & Capabilities** → Team 에 본인 Apple ID 선택
   (Bundle Identifier 가 겹치면 뒤에 아무 문자열이나 붙여 고유하게 변경)
2. 아이폰을 USB 연결(또는 같은 Wi-Fi 무선 디버깅) → 상단 기기 선택 → **Run(⌘R)**
3. 처음 실행 시 아이폰에서 **설정 > 일반 > VPN 및 기기 관리** 에서 개발자 앱 신뢰 필요

### 앱 아이콘 (선택)

Assets 카탈로그의 AppIcon 에 저장소의 `icons/icon-512.png` 를 1024×1024 로
리사이즈해 넣으면 홈 화면 아이콘이 적용됩니다.

## 로드 주소 변경

포크하거나 자체 호스팅하는 경우 `GGG/GGGApp.swift` 의 `appURL` 만 바꾸면 됩니다.
