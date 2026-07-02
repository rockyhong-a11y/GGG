// WKWebView 래퍼 + 햅틱 브리지
// 웹(app.js)의 haptic() 은 window.webkit.messageHandlers.haptic.postMessage("light"|"medium"|"strong")
// 을 호출한다. 여기서 받아 UIKit 피드백 제너레이터로 실제 Taptic 을 울린다.
// - light  → UISelectionFeedbackGenerator (휠 피커와 동일한 미세 틱 — 리스트 드래그 '드르륵' 용)
// - medium → UIImpactFeedbackGenerator(.medium)
// - strong → UIImpactFeedbackGenerator(.heavy)

import SwiftUI
import WebKit
import UIKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator(appHost: url.host) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true                    // 유튜브 임베드 인라인 재생
        config.userContentController.add(context.coordinator, name: "haptic")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never // 웹의 safe-area 처리에 맡김
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 13/255, green: 15/255, blue: 26/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
        private let appHost: String?
        private let selection = UISelectionFeedbackGenerator()
        private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)

        init(appHost: String?) {
            self.appHost = appHost
            super.init()
            selection.prepare()   // 첫 틱 지연 최소화
        }

        // MARK: 햅틱 브리지
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "haptic" else { return }
            switch message.body as? String {
            case "medium":
                impactMedium.impactOccurred()
                impactMedium.prepare()
            case "strong":
                impactHeavy.impactOccurred()
                impactHeavy.prepare()
            default: // "light" — 드래그 래칫 틱
                selection.selectionChanged()
                selection.prepare()
            }
        }

        // MARK: 외부 링크는 시스템 브라우저(사파리)로
        // target=_blank (window.open) — 인벤/루리웹 원문, 유튜브 링크 등
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url { UIApplication.shared.open(url) }
            return nil
        }

        // 같은 탭 내 이동이라도 앱 도메인 밖이면 사파리로
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               url.host != appHost {
                UIApplication.shared.open(url)
                return decisionHandler(.cancel)
            }
            decisionHandler(.allow)
        }
    }
}
