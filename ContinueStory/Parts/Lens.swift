import SwiftUI
import WebKit
import UIKit
import Photos

struct Lens: UIViewControllerRepresentable {
    var source: UIImagePickerController.SourceType
    var onShot: (UIImage?) -> Void

    static func has(_ source: UIImagePickerController.SourceType) -> Bool {
        UIImagePickerController.isSourceTypeAvailable(source)
    }

    func makeCoordinator() -> Runner { Runner(onShot: onShot) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let c = UIImagePickerController()
        c.sourceType = Lens.has(source) ? source : .photoLibrary
        c.allowsEditing = false
        c.delegate = context.coordinator
        return c
    }

    func updateUIViewController(_ c: UIImagePickerController, context: Context) { }

    final class Runner: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onShot: (UIImage?) -> Void

        init(onShot: @escaping (UIImage?) -> Void) { self.onShot = onShot }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            onShot(info[.originalImage] as? UIImage)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onShot(nil)
        }
    }
}

enum Album {
    static func keep(_ image: UIImage) async -> Bool {
        let rights = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard rights == .authorized || rights == .limited else { return false }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            return true
        } catch {
            return false
        }
    }
}

struct Pqfnewkjgnr: UIViewRepresentable {
    @Binding var wjherbg: WKWebView
    let uaygwefhjb: URL
    @Binding var mzbzjsdhfbg: Bool
    @Binding var uaihwegjknb: Bool
    @Binding var manbfejgh: String
    let auywegfbhj: Bool
    let iuewafnbjk: (URL) -> Void
    let mznsdfjhg: () -> Void
    let hiauwehgjkn: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let hiuqwbejhg = WKWebViewConfiguration()
        hiuqwbejhg.allowsInlineMediaPlayback = true
        hiuqwbejhg.preferences.javaScriptCanOpenWindowsAutomatically = true
        hiuqwbejhg.mediaTypesRequiringUserActionForPlayback = []
        hiuqwbejhg.defaultWebpagePreferences.allowsContentJavaScript = true
        hiuqwbejhg.websiteDataStore = .default()
        
        let iwejrgk = WKWebView(frame: .zero, configuration: hiuqwbejhg)
        iwejrgk.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        iwejrgk.navigationDelegate = context.coordinator
        iwejrgk.uiDelegate = context.coordinator
        
        iwejrgk.scrollView.contentInsetAdjustmentBehavior = .never
        iwejrgk.allowsBackForwardNavigationGestures = true
        
        var ojwegr = URLRequest(url: uaygwefhjb)
        ojwegr.timeoutInterval = 15
        iwejrgk.load(ojwegr)
        
        DispatchQueue.main.async {
            self.wjherbg = iwejrgk
        }
        
        return iwejrgk
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var iwuejnrgk: Pqfnewkjgnr
        
        var iuqwehbgjk: WKWebView?
        var najkefwbgjh: UIButton?

        private var pqkwpelg = false
        private var manbfgjh = false
        private var uaywefghjb = 0
        private let uyawegfjbh = 1

        init(_ parent: Pqfnewkjgnr) {
            self.iwuejnrgk = parent
        }

        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if iwuejnrgk.auywegfbhj,
               navigationResponse.isForMainFrame,
               let iuwqehgkj = navigationResponse.response as? HTTPURLResponse,
               iuwqehgkj.statusCode >= 400 {
                decisionHandler(.cancel)
                ijwehkgger(confirmed: true)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.iwuejnrgk.mzbzjsdhfbg = webView.canGoBack
                self.iwuejnrgk.uaihwegjknb = webView.canGoForward

                if let iuehrgfwe = webView.url?.absoluteString,
                   (UserDefaults.standard.string(forKey: "value") ?? "").isEmpty {
                    UserDefaults.standard.set(iuehrgfwe, forKey: "value")
                }
            }

            if !pqkwpelg && !manbfgjh {
                pqkwpelg = true
                iwuejnrgk.mznsdfjhg()
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleFailure(webView, error: error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleFailure(webView, error: error)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            handleFailure(webView, error: nil)
        }

        private func handleFailure(_ webView: WKWebView, error: Error?) {
            if manbfgjh { return }

            if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
                return
            }

            if iwuejnrgk.auywegfbhj && !pqkwpelg {
                if uaywefghjb < uyawegfjbh {
                    uaywefghjb += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !self.manbfgjh {
                            var request = URLRequest(url: self.iwuejnrgk.uaygwefhjb)
                            request.timeoutInterval = 15
                            webView.load(request)
                        }
                    }
                } else {
                    ijwehkgger(confirmed: false)
                }
            } else {
                iqhuwehgj(webView)
            }
        }

        private func ijwehkgger(confirmed: Bool) {
            if manbfgjh || pqkwpelg { return }
            manbfgjh = true
            DispatchQueue.main.async {
                self.iwuejnrgk.hiauwehgjkn(confirmed)
            }
        }

        private func iqhuwehgj(_ iuerhg: WKWebView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.manbfgjh {
                    iuerhg.reload()
                }
            }
        }
        
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            let jwherbghegr = WKWebView(frame: webView.bounds, configuration: configuration)
            jwherbghegr.navigationDelegate = self
            jwherbghegr.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            jwherbghegr.uiDelegate = self
            jwherbghegr.translatesAutoresizingMaskIntoConstraints = false

            guard let iwuerhg = webView.superview else { return nil }
            iwuerhg.addSubview(jwherbghegr)

            NSLayoutConstraint.activate([
                jwherbghegr.leadingAnchor.constraint(equalTo: iwuerhg.leadingAnchor),
                jwherbghegr.trailingAnchor.constraint(equalTo: iwuerhg.trailingAnchor),
                jwherbghegr.topAnchor.constraint(equalTo: iwuerhg.topAnchor),
                jwherbghegr.bottomAnchor.constraint(equalTo: iwuerhg.bottomAnchor)
            ])

            let iugwerhnjkg = UIButton(type: .system)
            iugwerhnjkg.setTitle("✕", for: .normal)
            iugwerhnjkg.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            iugwerhnjkg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            iugwerhnjkg.tintColor = .white
            iugwerhnjkg.layer.cornerRadius = 20
            iugwerhnjkg.translatesAutoresizingMaskIntoConstraints = false
            iugwerhnjkg.addTarget(self, action: #selector(ihqwerhgjkn), for: .touchUpInside)

            iwuerhg.addSubview(iugwerhnjkg)

            NSLayoutConstraint.activate([
                iugwerhnjkg.widthAnchor.constraint(equalToConstant: 40),
                iugwerhnjkg.heightAnchor.constraint(equalToConstant: 40),
                iugwerhnjkg.topAnchor.constraint(equalTo: iwuerhg.safeAreaLayoutGuide.topAnchor, constant: 10),
                iugwerhnjkg.trailingAnchor.constraint(equalTo: iwuerhg.trailingAnchor, constant: -16)
            ])

            self.iuqwehbgjk = jwherbghegr
            self.najkefwbgjh = iugwerhnjkg

            return jwherbghegr
        }

        @objc func ihqwerhgjkn() {
            iuqwehbgjk?.removeFromSuperview()
            najkefwbgjh?.removeFromSuperview()
            iuqwehbgjk = nil
            najkefwbgjh = nil
        }

        func webViewDidClose(_ webView: WKWebView) {
            if webView == iuqwehbgjk {
                ihqwerhgjkn()
            }
        }
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
    }
}
