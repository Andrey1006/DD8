import SwiftUI
import UserNotifications

private let privacyPolicyURL = URL(string: "https://storytimevault.pages.dev/#privacy")!

struct SettingsView: View {
    @EnvironmentObject private var vault: Vault
    @Environment(\.dismiss) private var dismiss

    @State private var alias = ""
    @State private var window: SealWindow = .standard
    @State private var rhythm: Rhythm = .weekly
    @State private var policyOpen = false
    @State private var burnAsked = false
    @State private var permission: UNAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            Backdrop(glow: Ink.past)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    Text("Settings")
                        .font(Face.display(34))
                        .foregroundColor(Ink.veil)

                    block("Signature") {
                        SlipField(text: $alias, hint: "your name in the archive", limit: 24)
                        Text("Both signatures on every story use this. Change it and the older ones change with you.")
                            .font(Face.body(12))
                            .foregroundColor(Ink.mute)
                    }

                    block("Default burial") {
                        HStack(spacing: 8) {
                            ForEach(SealWindow.allCases) { w in
                                Chip(text: w.title, on: window == w) { window = w }
                            }
                        }
                        Text(window.blurb)
                            .font(Face.body(12))
                            .foregroundColor(Ink.mute)
                    }

                    block("Nudges") {
                        HStack(spacing: 8) {
                            ForEach(Rhythm.allCases) { r in
                                Chip(text: r.title, on: rhythm == r) { rhythm = r }
                            }
                        }
                        permissionLine
                    }

                    block("Legal") {
                        row("Privacy Policy") { policyOpen = true }
                    }

                    block("Everything") {
                        Button("Break the vault") { burnAsked = true }
                            .buttonStyle(PressIn(tint: Ink.past))
                        Text("Wipes every opening, every finished story, the statistics and the demo pieces. The demo does not come back afterwards.")
                            .font(Face.body(12))
                            .foregroundColor(Ink.mute)
                            .lineSpacing(3)
                    }

                    Text("StoryTime Vault · archive format \(Vault.schema)")
                        .plateStyle(1.4, size: 8)
                        .foregroundColor(Ink.mute.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Text("← Drift").plateStyle(1.8, size: 10).foregroundColor(Ink.mute)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $policyOpen) {
            WebSheet(url: privacyPolicyURL)
        }
        .alert("Break the vault?", isPresented: $burnAsked) {
            Button("Cancel", role: .cancel) { }
            Button("Break it", role: .destructive) { vault.burnEverything() }
        } message: {
            Text("Everything sealed and everything finished is deleted for good. There is no copy anywhere else.")
        }
        .task {
            let a = vault.author
            alias = a?.alias ?? ""
            window = a?.window ?? .standard
            rhythm = a?.rhythm ?? .weekly
            permission = await Nudges.status()
        }
        .onDisappear(perform: keep)
    }

    @ViewBuilder
    private var permissionLine: some View {
        if permission == .denied && rhythm != .off {
            HStack(spacing: 10) {
                Circle().fill(Ink.past).frame(width: 6, height: 6)
                Text("iOS is blocking notifications for this app.")
                    .font(Face.body(12))
                    .foregroundColor(Ink.mute)
                Spacer(minLength: 0)
                Button("Fix") {
                    guard let u = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(u)
                }
                .buttonStyle(Ghost())
            }
        } else {
            Text(rhythm == .off
                 ? "Ripe pieces still come back on their own. This only turns off the pushes to start something new."
                 : "Separate from ripening, which always notifies.")
                .font(Face.body(12))
                .foregroundColor(Ink.mute)
        }
    }

    private func block<C: View>(_ head: String, @ViewBuilder body: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Plate(text: head)
            body()
        }
    }

    private func row(_ text: String, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack {
                Text(text)
                    .font(Face.body(15, .medium))
                    .foregroundColor(Ink.veil)
                Spacer()
                Text("↗").font(Face.display(16)).foregroundColor(Ink.mute)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .slab(cut: 12, corners: [.tr, .bl], fill: Ink.slab.opacity(0.45))
        }
        .buttonStyle(.plain)
    }

    private func keep() {
        guard var a = vault.author else { return }
        let trimmed = alias.trimmingCharacters(in: .whitespacesAndNewlines)
        a.alias = trimmed.isEmpty ? a.alias : trimmed
        a.window = window
        let rhythmChanged = a.rhythm != rhythm
        a.rhythm = rhythm
        vault.adopt(a)
        if rhythmChanged && rhythm != .off && permission == .notDetermined {
            Task { _ = await Nudges.ask() }
        }
    }
}
