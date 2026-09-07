import SwiftUI

struct SealView: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    @State private var salt = 0
    @State private var window: SealWindow?
    @State private var landed: Piece?
    @State private var dial = 0

    private var spark: Spark {
        Sparks.forToday(vault.author?.tones ?? Array(Tone.allCases.prefix(3)), salt: salt)
    }

    private var live: SealWindow { window ?? vault.author?.window ?? .standard }

    var body: some View {
        ZStack {
            composer
                .blur(radius: landed == nil ? 0 : 14)
                .opacity(landed == nil ? 1 : 0.25)
                .allowsHitTesting(landed == nil)

            if let landed {
                verdict(landed)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: landed)
    }

    private var composer: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .firstTextBaseline) {
                    Text("New opening")
                        .font(Face.display(34))
                        .foregroundColor(Ink.veil)
                    Spacer()
                    Text("\(deck.draft.count)/\(Deck.inkLimit)")
                        .plateStyle(1.4, size: 9)
                        .foregroundColor(deck.quill > 0.92 ? Ink.past : Ink.mute)
                }

                sparkCard

                HStack(alignment: .top, spacing: 14) {
                    PaperField(
                        text: $deck.draft,
                        hint: "Two or three sentences. Leave it hanging.",
                        tint: Ink.past,
                        limit: Deck.inkLimit,
                        minHeight: 190
                    )
                    Quill(fill: deck.quill, tint: Ink.past).frame(height: 190)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Plate(text: "Tone at sealing", trailing: deck.mood.title)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Tone.allCases) { t in
                                Chip(text: t.title, on: deck.mood == t, tint: t.tint) { deck.mood = t }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Plate(text: "Buried for", trailing: live.title)
                    HStack(spacing: 8) {
                        ForEach(SealWindow.allCases) { w in
                            Chip(text: w.title, on: live == w) { window = w }
                        }
                    }
                    Text(live.blurb)
                        .font(Face.body(12))
                        .foregroundColor(Ink.mute)
                }

                WaxPull(armed: armed) { fire() }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 130)
        }
    }

    private var sparkCard: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Spark")
                    .plateStyle(2, size: 9)
                    .foregroundColor(Ink.now)
                Text(spark.text)
                    .font(Face.story(15))
                    .foregroundColor(Ink.veil.opacity(0.9))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            VStack(spacing: 14) {
                Button {
                    Buzz.tap()
                    salt += 1
                } label: {
                    Circle()
                        .stroke(Ink.hair, lineWidth: 1)
                        .frame(width: 30, height: 30)
                        .overlay(Text("↻").font(Face.body(14)).foregroundColor(Ink.mute))
                }
                Button {
                    Buzz.tap()
                    deck.draft = spark.text + " "
                } label: {
                    Circle()
                        .stroke(Ink.now.opacity(0.6), lineWidth: 1)
                        .frame(width: 30, height: 30)
                        .overlay(Text("↓").font(Face.body(14)).foregroundColor(Ink.now))
                }
            }
        }
        .padding(16)
        .slab(cut: 14, corners: [.tr, .bl], fill: Ink.slab.opacity(0.55))
    }

    private var armed: Bool {
        deck.draft.trimmingCharacters(in: .whitespacesAndNewlines).count >= 40
    }

    private func fire() {
        let p = vault.seal(deck.draft, tone: deck.mood, spark: spark.text, window: live)
        deck.draft = ""
        landed = p
        spinDial()
    }

    private func spinDial() {
        Task {
            for i in 0..<9 {
                await MainActor.run { dial = i }
                try? await Task.sleep(nanoseconds: UInt64(60_000_000 + i * 12_000_000))
            }
            await MainActor.run { dial = -1 }
        }
    }

    private func verdict(_ p: Piece) -> some View {
        let faces = ["hours away", "a couple of days", "this week", "a week or so", "a few weeks", "over a month"]

        return VStack(spacing: 26) {
            SealFace(size: 92)

            VStack(spacing: 12) {
                Text("Sealed")
                    .plateStyle(3, size: 11)
                    .foregroundColor(Ink.mute)

                Text(dial < 0 ? p.waitWording() : faces[dial % faces.count])
                    .font(Face.display(40))
                    .foregroundColor(dial < 0 ? Ink.now : Ink.mute.opacity(0.5))
                    .animation(.none, value: dial)

                Text(dial < 0 ? "The exact day is rolled and hidden. You will hear about it." : "rolling")
                    .font(Face.body(14))
                    .foregroundColor(Ink.mute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if dial < 0 {
                Button("Back to the desk") {
                    landed = nil
                    deck.open(.tonight)
                }
                .buttonStyle(PressIn())
                .frame(maxWidth: 240)
                .transition(.opacity)
            }
        }
        .padding(30)
    }
}
