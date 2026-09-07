import SwiftUI

@main
struct ContinueStoryApp: App {
    @StateObject private var vault = Vault()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if vault.onboarded {
                    Deckhouse()
                        .transition(.opacity.combined(with: .scale(scale: 1.03)))
                } else {
                    Intro()
                        .transition(.opacity)
                }
            }
            .environmentObject(vault)
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.45), value: vault.onboarded)
        }
    }
}
