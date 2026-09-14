import SwiftUI
import UIKit

struct SealView: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    @State private var salt = 0
    @State private var window: SealWindow?
    @State private var landed: Piece?
    @State private var dial = 0
    @State private var shot: UIImage?
    @State private var lens: UIImagePickerController.SourceType?

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

                pinRow

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
        .fullScreenCover(item: Binding(
            get: { lens.map(Source.init) },
            set: { lens = $0?.kind }
        )) { source in
            Lens(source: source.kind) { picked in
                if let picked { shot = picked }
                lens = nil
            }
            .ignoresSafeArea()
        }
    }

    private var pinRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Plate(text: "Pin something to it", trailing: shot == nil ? "optional" : "pinned")

            HStack(spacing: 12) {
                if let shot {
                    Image(uiImage: shot)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 92)
                        .clipped()
                        .clipShape(Chamfer(cut: 10, corners: .diagonal))
                        .overlay(Chamfer(cut: 10, corners: .diagonal).stroke(Ink.past.opacity(0.5), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sealed with the words")
                            .plateStyle(1.6, size: 9)
                            .foregroundColor(Ink.past)
                        Button("Take it off") { self.shot = nil }
                            .buttonStyle(Ghost())
                    }
                } else {
                    slot("Camera", tint: Ink.past) { lens = .camera }
                    slot("Library", tint: Ink.now) { lens = .photoLibrary }
                }

                Spacer(minLength: 0)
            }

            Text(shot == nil
                 ? "One photo from today, buried with the opening. You see it again only when the piece comes back."
                 : "It stays out of sight until the seal breaks.")
                .font(Face.body(12))
                .foregroundColor(Ink.mute)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func slot(_ text: String, tint: Color, tap: @escaping () -> Void) -> some View {
        Button {
            Buzz.tap()
            tap()
        } label: {
            VStack(spacing: 8) {
                Chamfer(cut: 6, corners: .all)
                    .stroke(tint.opacity(0.7), lineWidth: 1.4)
                    .frame(width: 22, height: 18)
                    .overlay(Circle().stroke(tint.opacity(0.7), lineWidth: 1.4).frame(width: 9, height: 9))
                Text(text)
                    .plateStyle(1.4, size: 9)
                    .foregroundColor(Ink.veil.opacity(0.85))
            }
            .frame(width: 92, height: 92)
            .slab(cut: 10, corners: .diagonal, fill: Ink.slab.opacity(0.55), stroke: Ink.hair)
        }
        .buttonStyle(.plain)
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
        let kept = shot.flatMap(Shots.keep)
        let p = vault.seal(deck.draft, tone: deck.mood, spark: spark.text, window: live, photo: kept)
        deck.draft = ""
        shot = nil
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


private struct Source: Identifiable {
    let kind: UIImagePickerController.SourceType
    var id: Int { kind.rawValue }
}
