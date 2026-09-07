import SwiftUI

struct Intro: View {
    @EnvironmentObject private var vault: Vault

    @State private var stage = 0
    @State private var alias = ""
    @State private var picked: Set<Tone> = []
    @State private var window: SealWindow = .standard
    @State private var rhythm: Rhythm = .weekly
    @State private var opening = ""
    @State private var mood: Tone = .dread
    @State private var back = false

    private let last = 4

    var body: some View {
        ZStack {
            Backdrop(glow: stage == last ? Ink.past : Ink.now)

            VStack(alignment: .leading, spacing: 0) {
                rail
                    .padding(.horizontal, 26)
                    .padding(.top, 14)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        heading
                        stageBody
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 34)
                    .padding(.bottom, 40)
                }

                footer
                    .padding(.horizontal, 26)
                    .padding(.bottom, 12)
            }
        }
    }

    private var rail: some View {
        HStack(spacing: 6) {
            ForEach(0...last, id: \.self) { i in
                Rectangle()
                    .fill(i <= stage ? Ink.now : Ink.hair)
                    .frame(height: 2)
            }
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step \(stage + 1) of \(last + 1)")
                .plateStyle(2.4, size: 9)
                .foregroundColor(Ink.mute)

            Text(title)
                .font(Face.display(38))
                .foregroundColor(Ink.veil)
                .fixedSize(horizontal: false, vertical: true)

            Text(sub)
                .font(Face.body(15))
                .foregroundColor(Ink.mute)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .id(stage)
        .transition(.asymmetric(
            insertion: .move(edge: back ? .leading : .trailing).combined(with: .opacity),
            removal: .opacity
        ))
    }

    @ViewBuilder
    private var stageBody: some View {
        switch stage {
        case 0:
            SlipField(text: $alias, hint: "e.g. Nine, or your own name", limit: 24, autofocus: true)
        case 1:
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Tone.allCases) { t in
                    toneCard(t)
                }
            }
        case 2:
            VStack(spacing: 12) {
                ForEach(SealWindow.allCases) { w in
                    choice(w.title, w.blurb, on: window == w) { window = w }
                }
            }
        case 3:
            VStack(spacing: 12) {
                ForEach(Rhythm.allCases) { r in
                    choice(r.title, blurb(r), on: rhythm == r) { rhythm = r }
                }
            }
        default:
            firstSeal
        }
    }

    private var footer: some View {
        HStack(spacing: 14) {
            if stage > 0 && stage != last {
                Button("Back") {
                    back = true
                    withAnimation(.easeInOut(duration: 0.3)) { stage -= 1 }
                }
                .buttonStyle(Ghost())
            }

            if stage != last {
                Button(stage == 3 ? "Write the first one" : "Next") {
                    back = false
                    if stage == 3 { askIfNeeded() }
                    withAnimation(.easeInOut(duration: 0.3)) { stage += 1 }
                }
                .buttonStyle(PressIn(tint: Ink.now, solid: true))
                .disabled(!ready)
                .opacity(ready ? 1 : 0.35)
            }
        }
    }

    private func toneCard(_ t: Tone) -> some View {
        let on = picked.contains(t)
        return Button {
            Buzz.tap()
            if on {
                picked.remove(t)
            } else if picked.count < 3 {
                picked.insert(t)
            } else {
                Buzz.tap(.rigid)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 7) {
                    ToneDot(tone: t, size: 8)
                    Text(t.title)
                        .plateStyle(1.4, size: 11)
                        .foregroundColor(Ink.veil)
                }
                Text(t.blurb)
                    .font(Face.body(12))
                    .foregroundColor(Ink.mute)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .slab(cut: 12, corners: .diagonal, fill: on ? Ink.slab : Ink.slab.opacity(0.45), stroke: on ? t.tint : Ink.hair)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: on)
    }

    private func choice(_ head: String, _ line: String, on: Bool, tap: @escaping () -> Void) -> some View {
        Button {
            Buzz.tap()
            tap()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Chamfer(cut: 5, corners: .all)
                    .stroke(on ? Ink.now : Ink.hair, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                    .overlay(Chamfer(cut: 3, corners: .all).fill(on ? Ink.now : .clear).frame(width: 7, height: 7))
                    .padding(.top, 3)

                VStack(alignment: .leading, spacing: 6) {
                    Text(head)
                        .plateStyle(1.4, size: 11)
                        .foregroundColor(Ink.veil)
                    Text(line)
                        .font(Face.body(13))
                        .foregroundColor(Ink.mute)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .slab(cut: 12, corners: .diagonal, fill: on ? Ink.slab : Ink.slab.opacity(0.4), stroke: on ? Ink.now.opacity(0.6) : Ink.hair)
        }
        .buttonStyle(.plain)
    }

    private var firstSeal: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                PaperField(text: $opening, hint: "Two or three sentences. No ending. Do not plan one.", tint: Ink.past, limit: 280, minHeight: 168, autofocus: true)
                Quill(fill: Double(opening.count) / 280, tint: Ink.past)
                    .frame(height: 168)
            }

            VStack(alignment: .leading, spacing: 12) {
                Plate(text: "How does it feel", trailing: mood.title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Tone.allCases) { t in
                            Chip(text: t.title, on: mood == t, tint: t.tint) { mood = t }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            WaxPull(armed: opening.trimmingCharacters(in: .whitespaces).count >= 40) {
                commit()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    private var title: String {
        switch stage {
        case 0: return "What should the archive call you?"
        case 1: return "Pick three ways you write"
        case 2: return "How long should it stay buried?"
        case 3: return "Should the app poke you?"
        default: return "Now start something"
        }
    }

    private var sub: String {
        switch stage {
        case 0: return "Every finished story gets signed twice — by the you who started it and the you who ended it. Same name, different person."
        case 1: return "This picks the openings you get offered, and it is one half of how drift gets measured later."
        case 2: return "The exact date is rolled at random inside the window and never shown to you. You get a vague sense, nothing more."
        case 3: return "Separate from the moment a sealed piece ripens — that one always comes back on its own."
        default: return "Do not write an ending. That is not your job today — it belongs to whoever you turn into in \(handoff)."
        }
    }

    private var handoff: String {
        switch window {
        case .short: return "a week or two"
        case .standard: return "a few weeks"
        case .long: return "a month or two"
        }
    }

    private func blurb(_ r: Rhythm) -> String {
        switch r {
        case .off: return "No reminders. You come back when you come back."
        case .weekly: return "One nudge a week to start something new."
        case .brisk: return "Every third day. For people who need the push."
        }
    }

    private var ready: Bool {
        switch stage {
        case 0: return alias.trimmingCharacters(in: .whitespaces).count >= 2
        case 1: return picked.count == 3
        default: return true
        }
    }

    private func askIfNeeded() {
        guard rhythm != .off else { return }
        Task {
            let granted = await Nudges.ask()
            await MainActor.run { vault.nudgesBlocked = !granted }
        }
    }

    private func commit() {
        vault.plantDemoIfVirgin()
        vault.seal(opening, tone: mood, window: window)
        vault.adopt(Author(
            alias: alias.trimmingCharacters(in: .whitespacesAndNewlines),
            tones: Array(picked),
            window: window,
            rhythm: rhythm,
            joinedAt: Date()
        ))
    }
}
