import SwiftUI
import WebKit

struct WebSheet: View {
    let url: URL
    var heading = "Privacy Policy"

    @Environment(\.dismiss) private var dismiss
    @State private var loading = true
    @State private var broke = false
    @State private var attempt = 0

    var body: some View {
        ZStack {
            Backdrop(glow: Ink.past)

            VStack(spacing: 0) {
                HStack {
                    Text(heading)
                        .plateStyle(2.4, size: 11)
                        .foregroundColor(Ink.veil)
                    Spacer()
                    Button("Close") { dismiss() }.buttonStyle(Ghost())
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 18)

                Rectangle().fill(Ink.hair).frame(height: 1)

                ZStack {
                    if broke {
                        offline
                    } else {
                        Paper(url: url, attempt: attempt, loading: $loading, broke: $broke)
                            .opacity(loading ? 0 : 1)
                    }

                    if loading && !broke {
                        VStack(spacing: 14) {
                            ProgressView().tint(Ink.now)
                            Text("fetching")
                                .plateStyle(2.4, size: 9)
                                .foregroundColor(Ink.mute)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private var offline: some View {
        VStack(spacing: 16) {
            Text("Nothing came through")
                .font(Face.display(26))
                .foregroundColor(Ink.veil)
            Text("The policy lives online and the network did not answer. Check the connection and pull it again.")
                .font(Face.body(14))
                .foregroundColor(Ink.mute)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Button("Try again") {
                broke = false
                loading = true
                attempt += 1
            }
            .buttonStyle(PressIn())
            .frame(width: 200)
        }
        .padding(34)
    }
}

private struct Paper: UIViewRepresentable {
    let url: URL
    let attempt: Int
    @Binding var loading: Bool
    @Binding var broke: Bool

    func makeCoordinator() -> Pilot { Pilot(self) }

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        web.navigationDelegate = context.coordinator
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear
        web.scrollView.showsVerticalScrollIndicator = false
        web.load(URLRequest(url: url))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        guard context.coordinator.served != attempt else { return }
        context.coordinator.served = attempt
        web.load(URLRequest(url: url))
    }

    final class Pilot: NSObject, WKNavigationDelegate {
        var served = 0
        private let host: Paper

        init(_ host: Paper) { self.host = host }

        func webView(_ w: WKWebView, didStartProvisionalNavigation n: WKNavigation!) {
            host.loading = true
        }

        func webView(_ w: WKWebView, didFinish n: WKNavigation!) {
            host.loading = false
        }

        func webView(_ w: WKWebView, didFail n: WKNavigation!, withError e: Error) {
            host.loading = false
            host.broke = true
        }

        func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) {
            host.loading = false
            host.broke = true
        }
    }
}
