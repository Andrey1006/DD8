import SwiftUI

struct RitualView: View {
    let id: UUID

    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    private enum Step { case tear, recall, wipe, write, done }

    @State private var step: Step = .tear
    @State private var guess = ""
    @State private var ending = ""
    @State private var mood: Tone = .tender
    @State private var finished: Piece?

    var body: some View {
        ZStack {
            Backdrop(glow: step == .done ? Ink.now : Ink.past)

            if let p = vault.piece(id) {
                VStack(spacing: 0) {
                    topBar(p)

                    Group {
                        switch step {
                        case .tear: tear(p)
                        case .recall: recallStep(p)
                        case .wipe: wipeStep(p)
                        case .write: writeStep(p)
                        case .done: doneStep()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                Nothing(title: "It slipped away", line: "This piece is no longer in the vault.")
            }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    private func topBar(_ p: Piece) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(step == .done ? "Finished" : "Sealed \(Stamp.day(p.sealedAt))")
                    .plateStyle(2.2, size: 9)
                    .foregroundColor(Ink.mute)
                Text(step == .done ? "" : Stamp.gap(p.gapDays))
                    .plateStyle(1.4, size: 9)
                    .foregroundColor(Ink.past.opacity(0.8))
            }
            Spacer()
            if step != .done {
                Button("Leave it") { deck.ritual = nil }
                    .buttonStyle(Ghost())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
    }

    private func tear(_ p: Piece) -> some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Something you wrote\n\(p.gapDays) days ago")
                .font(Face.display(34))
                .multilineTextAlignment(.center)
                .foregroundColor(Ink.veil)

            WaxTear { step = .recall }

            Text("Do not try to remember yet.")
                .font(Face.body(13))
                .foregroundColor(Ink.mute)
            Spacer()
        }
        .padding(.horizontal, 26)
    }

    private func recallStep(_ p: Piece) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            Spacer()
            Text("What do you think you wrote?")
                .font(Face.display(36))
                .foregroundColor(Ink.veil)
                .fixedSize(horizontal: false, vertical: true)

            Text("One line, from memory. It gets stored next to the real thing, and you will see how close you were.")
                .font(Face.body(14))
                .foregroundColor(Ink.mute)
                .lineSpacing(5)

            SlipField(text: $guess, hint: "a bakery, maybe a fire", tint: Ink.past, limit: 90, autofocus: true)

            HStack(spacing: 16) {
                Button("I have nothing") {
                    guess = ""
                    step = .wipe
                }
                .buttonStyle(Ghost())

                Button("Lock it in") { step = .wipe }
                    .buttonStyle(PressIn(tint: Ink.past, solid: true))
                    .disabled(guess.trimmingCharacters(in: .whitespaces).count < 3)
                    .opacity(guess.trimmingCharacters(in: .whitespaces).count < 3 ? 0.35 : 1)
            }
            Spacer()
        }
        .padding(.horizontal, 26)
    }

    private func wipeStep(_ p: Piece) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Wipe it clear")
                .font(Face.display(30))
                .foregroundColor(Ink.veil)

            Smear(text: p.opening) { step = .write }
                .frame(maxHeight: .infinity)

            Text("Drag your finger across until the whole thing shows.")
                .font(Face.body(12))
                .foregroundColor(Ink.mute)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 26)
    }

    private func writeStep(_ p: Piece) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                Text(p.opening)
                    .font(Face.story(17))
                    .lineSpacing(7)
                    .foregroundColor(Ink.past)
                    .fixedSize(horizontal: false, vertical: true)

                if let name = p.photo, let img = Shots.load(name) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 210)
                            .clipped()
                            .clipShape(Chamfer(cut: 14, corners: .diagonal))
                            .overlay(Chamfer(cut: 14, corners: .diagonal).stroke(Ink.past.opacity(0.4), lineWidth: 1))
                        Text("pinned the day you buried it")
                            .plateStyle(1.6, size: 9)
                            .foregroundColor(Ink.mute)
                    }
                }

                Plate(text: "Now end it")

                PaperField(
                    text: $ending,
                    hint: "However it ends. You do not owe the beginning anything.",
                    tint: Ink.now,
                    minHeight: 210,
                    autofocus: true
                )

                VStack(alignment: .leading, spacing: 12) {
                    Plate(text: "Tone right now", trailing: mood.title)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Tone.allCases) { t in
                                Chip(text: t.title, on: mood == t, tint: t.tint) { mood = t }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Button("Close the story") { seal(p) }
                    .buttonStyle(PressIn(tint: Ink.now, solid: true))
                    .disabled(ending.trimmingCharacters(in: .whitespaces).count < 40)
                    .opacity(ending.trimmingCharacters(in: .whitespaces).count < 40 ? 0.35 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func doneStep() -> some View {
        let p = finished

        return VStack(spacing: 26) {
            Spacer()

            if let p {
                Cover(piece: p)
                    .frame(width: 132, height: 176)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)

                VStack(spacing: 10) {
                    Text("\(p.drift ?? 0)")
                        .font(Face.display(66))
                        .foregroundColor(Ink.now)
                    Text("drift")
                        .plateStyle(3, size: 9)
                        .foregroundColor(Ink.mute)
                    Text(Drift.verdict(p.drift ?? 0))
                        .font(Face.display(26))
                        .foregroundColor(Ink.veil)
                        .multilineTextAlignment(.center)
                }

                Text(Drift.hit(p)
                     ? "Your guess held a thread of it."
                     : "Your guess had nothing in common with it.")
                    .font(Face.body(13))
                    .foregroundColor(Ink.mute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button("Read it whole") {
                    deck.ritual = nil
                    deck.slot = .shelf
                    if let p { deck.read(p.id, from: .shelf) }
                }
                .buttonStyle(PressIn(tint: Ink.now, solid: true))

                Button("Put it on the shelf") {
                    deck.ritual = nil
                    deck.slot = .shelf
                }
                .buttonStyle(Ghost())
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 22)
        }
    }

    private func seal(_ p: Piece) {
        vault.close(p.id, text: ending, tone: mood, guess: guess.isEmpty ? nil : guess)
        finished = vault.piece(p.id)
        Buzz.snap()
        step = .done
    }
}
