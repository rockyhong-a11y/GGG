// GGG — Good Game, Gallantly · iOS WebView 래퍼
// 배포된 웹앱(GitHub Pages)을 WKWebView 로 로드하고, 웹의 haptic() 호출을
// 네이티브 Taptic Engine(UIKit 피드백 제너레이터)으로 전달한다.
// 웹이 업데이트되면 앱 재설치 없이 자동 반영된다.

import SwiftUI

@main
struct GGGApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // 앱이 로드할 웹앱 주소 (포크/자체 호스팅 시 여기만 변경)
    private let appURL = URL(string: "https://rockyhong-a11y.github.io/GGG/")!

    var body: some View {
        WebView(url: appURL)
            .ignoresSafeArea()                       // 웹이 viewport-fit=cover 로 safe-area 를 직접 처리
            .background(Color(red: 13/255, green: 15/255, blue: 26/255)) // 웹 다크 배경과 동일
            .preferredColorScheme(.dark)
    }
}
