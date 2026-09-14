
import SwiftUI
import WebKit

struct Kfnejgwkrnjk: View {
    let jkgernwjgwe: URL
    let hiqwefgjhkq: (() -> Void)?
    let qihergnjk: ((Bool) -> Void)?

    @State private var hiwernjg = WKWebView()
    @State private var uygwefhja = false
    @State private var iuwqegnkj = false

    @State private var oiawjengjk: URL?
    @State private var iuqenrkgj = false

    @AppStorage("value") private var uyqwegfb: String = ""
    
    init(jkgernwjgwe: URL, hiqwefgjhkq: (() -> Void)? = nil, qihergnjk: ((Bool) -> Void)? = nil) {
        self.jkgernwjgwe = jkgernwjgwe
        self.hiqwefgjhkq = hiqwefgjhkq
        self.qihergnjk = qihergnjk
    }

    var body: some View {
        VStack(spacing: 0) {

            Pqfnewkjgnr(
                wjherbg: $hiwernjg,
                uaygwefhjb: jkgernwjgwe,
                mzbzjsdhfbg: $uygwefhja,
                uaihwegjknb: $iuwqegnkj,
                manbfejgh: $uyqwegfb,
                auywegfbhj: qihergnjk != nil,
                iuewafnbjk: { url in
                    oiawjengjk = url
                    iuqenrkgj = true
                },
                mznsdfjhg: {
                    hiqwefgjhkq?()
                },
                hiauwehgjkn: { confirmed in
                    qihergnjk?(confirmed)
                }
            )

            HStack {
                Button {
                    if hiwernjg.canGoBack { hiwernjg.goBack() }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .foregroundColor(uygwefhja ? .white : .gray)
                }

                Spacer()

                Button {
                    if hiwernjg.canGoForward { hiwernjg.goForward() }
                } label: {
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundColor(iuwqegnkj ? .white : .gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(Color.black)
        }
        .background(Color.black)
        .sheet(isPresented: $iuqenrkgj) {
            if let oiawjengjk {
                Kfbjkgrebkjner(wjoierg: oiawjengjk)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
