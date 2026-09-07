import SwiftUI

struct DriftRoom: View {
    @EnvironmentObject private var vault: Vault
    @EnvironmentObject private var deck: Deck

    @State private var scrub: Int?

    private var closed: [Piece] {
        vault.done.sorted { ($0.closedAt ?? .distantPast) < ($1.closedAt ?? .distantPast) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The two of you")
                        .font(Face.display(34))
                        .foregroundColor(Ink.veil)
                    Text(closed.isEmpty ? "no readings yet" : "\(closed.count) finished · drift is the distance between who starts and who ends")
                        .plateStyle(1.6, size: 9)
                        .foregroundColor(Ink.mute)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if closed.isEmpty {
                    Nothing(
                        title: "Nothing to measure",
                        line: "The moment you finish your first sealed opening, this room starts telling you how far apart the two of you are.",
                        cta: vault.ripe.isEmpty ? "Bury an opening" : "Open the ripe one"
                    ) {
                        if let r = vault.ripe.first { deck.ritual = r.id } else { deck.open(.seal) }
                    }
                } else {
                    petals
                    timeline
                    numbers
                }

                settingsRow
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 130)
        }
    }

    private var petals: some View {
        VStack(alignment: .leading, spacing: 16) {
            Plate(text: "Where you start / where you end")

            Petals(open: tally(\.toneAtSeal), shut: tallyClose())
                .frame(height: 240)

            HStack(spacing: 18) {
                legend(Ink.past, "sealed in")
                legend(Ink.now, "finished in")
            }

            Text(pull)
                .font(Face.body(13))
                .foregroundColor(Ink.mute)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .slab(cut: 18, corners: .diagonal, fill: Ink.slab.opacity(0.55))
    }

    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 7) {
            Circle().fill(c).frame(width: 7, height: 7)
            Text(t).plateStyle(1.4, size: 9).foregroundColor(Ink.mute)
        }
    }

    private func tally(_ key: KeyPath<Piece, Tone>) -> [Tone: Int] {
        closed.reduce(into: [:]) { acc, p in acc[p[keyPath: key], default: 0] += 1 }
    }

    private func tallyClose() -> [Tone: Int] {
        closed.reduce(into: [:]) { acc, p in
            guard let t = p.toneAtClose else { return }
            acc[t, default: 0] += 1
        }
    }

    private var pull: String {
        let a = closed.map(\.toneAtSeal.warmth).reduce(0, +) / Double(closed.count)
        let b = closed.compactMap { $0.toneAtClose?.warmth }
        guard !b.isEmpty else { return "" }
        let delta = b.reduce(0, +) / Double(b.count) - a
        if delta > 0.12 { return "You start cold and finish warm. Whoever picks these up is kinder than whoever buried them." }
        if delta < -0.12 { return "You start warm and finish cold. Time takes the softness out of your endings." }
        return "You end roughly where you start. The gap changes the words, not the temperature."
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            Plate(text: "Drift over time", trailing: scrub == nil ? "drag me" : Stamp.day(closed[scrub!].closedAt ?? Date()))

            Line(values: closed.map { Double($0.drift ?? 0) }, mark: $scrub)
                .frame(height: 150)

            if let i = scrub {
                let p = closed[i]
                HStack(spacing: 14) {
                    Cover(piece: p).frame(width: 42, height: 56)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("drift \(p.drift ?? 0) · \(Stamp.gap(p.gapDays))")
                            .plateStyle(1.4, size: 9)
                            .foregroundColor(Ink.now)
                        Text(p.opening)
                            .font(Face.body(12))
                            .foregroundColor(Ink.mute)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .transition(.opacity)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .slab(cut: 18, corners: [.tr, .bl], fill: Ink.slab.opacity(0.55))
    }

    private var numbers: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Figure(value: "\(Int(avgDrift))", caption: "average drift", tint: Ink.now)
                Figure(value: "\(closed.map(\.gapDays).max() ?? 0)", caption: "longest gap, days", tint: Ink.past)
            }
            HStack(spacing: 12) {
                Figure(value: "\(hits)%", caption: "guesses that hit")
                Figure(value: "\(vault.pieces.filter(\.cracked).count)", caption: "seals broken early", tint: Ink.past)
            }
        }
    }

    private var avgDrift: Double {
        Double(closed.compactMap(\.drift).reduce(0, +)) / Double(max(1, closed.count))
    }

    private var hits: Int {
        let asked = closed.filter { !($0.guess ?? "").isEmpty }
        guard !asked.isEmpty else { return 0 }
        return Int(Double(asked.filter(Drift.hit).count) / Double(asked.count) * 100)
    }

    private var settingsRow: some View {
        Button {
            deck.driftPath.append(.settings)
        } label: {
            HStack {
                Text("Settings, policy, wiping it all")
                    .plateStyle(1.6, size: 10)
                    .foregroundColor(Ink.veil)
                Spacer()
                Text("→").font(Face.display(18)).foregroundColor(Ink.mute)
            }
            .padding(18)
            .slab(cut: 12, corners: .diagonal, fill: Ink.slab.opacity(0.45))
        }
        .buttonStyle(.plain)
    }
}

private struct Petals: View {
    let open: [Tone: Int]
    let shut: [Tone: Int]

    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let rad = min(size.width, size.height) / 2 - 26
            let tones = Tone.allCases
            let top = Double(max(open.values.max() ?? 1, shut.values.max() ?? 1))

            for f in [0.34, 0.67, 1.0] {
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: c.x - rad * f, y: c.y - rad * f, width: rad * 2 * f, height: rad * 2 * f)),
                    with: .color(Ink.hair.opacity(0.7)),
                    lineWidth: 1
                )
            }

            for (i, t) in tones.enumerated() {
                let a = angle(i, of: tones.count)
                var spoke = Path()
                spoke.move(to: c)
                spoke.addLine(to: CGPoint(x: c.x + cos(a) * rad, y: c.y + sin(a) * rad))
                ctx.stroke(spoke, with: .color(Ink.hair.opacity(0.5)), lineWidth: 1)

                let lp = CGPoint(x: c.x + cos(a) * (rad + 15), y: c.y + sin(a) * (rad + 15))
                ctx.draw(
                    Text(t.title).font(Face.plate(8)).foregroundColor(Ink.mute),
                    at: lp
                )
            }

            ctx.fill(web(open, c: c, rad: rad, top: top), with: .color(Ink.past.opacity(0.28)))
            ctx.stroke(web(open, c: c, rad: rad, top: top), with: .color(Ink.past), lineWidth: 1.5)
            ctx.fill(web(shut, c: c, rad: rad, top: top), with: .color(Ink.now.opacity(0.24)))
            ctx.stroke(web(shut, c: c, rad: rad, top: top), with: .color(Ink.now), lineWidth: 1.5)
        }
    }

    private func angle(_ i: Int, of n: Int) -> Double {
        -Double.pi / 2 + Double(i) / Double(n) * .pi * 2
    }

    private func web(_ counts: [Tone: Int], c: CGPoint, rad: Double, top: Double) -> Path {
        var p = Path()
        let tones = Tone.allCases
        for (i, t) in tones.enumerated() {
            let v = Double(counts[t] ?? 0) / max(1, top)
            let a = angle(i, of: tones.count)
            let r = 6 + v * (rad - 6)
            let pt = CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

private struct Line: View {
    let values: [Double]
    @Binding var mark: Int?

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pts = spots(w: w, h: h)

            ZStack(alignment: .topLeading) {
                Canvas { ctx, _ in
                    for f in [0.0, 0.5, 1.0] {
                        var g = Path()
                        g.move(to: CGPoint(x: 0, y: h * f))
                        g.addLine(to: CGPoint(x: w, y: h * f))
                        ctx.stroke(g, with: .color(Ink.hair.opacity(0.6)), lineWidth: 1)
                    }

                    guard pts.count > 1 else { return }
                    var trace = Path()
                    trace.move(to: pts[0])
                    for p in pts.dropFirst() { trace.addLine(to: p) }
                    ctx.stroke(trace, with: .color(Ink.now), style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                    var under = trace
                    under.addLine(to: CGPoint(x: pts.last!.x, y: h))
                    under.addLine(to: CGPoint(x: pts[0].x, y: h))
                    under.closeSubpath()
                    ctx.fill(under, with: .linearGradient(
                        Gradient(colors: [Ink.now.opacity(0.22), .clear]),
                        startPoint: .zero, endPoint: CGPoint(x: 0, y: h)
                    ))
                }

                ForEach(Array(pts.enumerated()), id: \.offset) { i, p in
                    Circle()
                        .fill(mark == i ? Ink.past : Ink.now)
                        .frame(width: mark == i ? 11 : 6, height: mark == i ? 11 : 6)
                        .position(p)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        guard !pts.isEmpty else { return }
                        let step = pts.count > 1 ? w / Double(pts.count - 1) : w
                        let i = min(pts.count - 1, max(0, Int((v.location.x / step).rounded())))
                        if mark != i { Buzz.tap(.soft) }
                        mark = i
                    }
            )
        }
    }

    private func spots(w: Double, h: Double) -> [CGPoint] {
        guard !values.isEmpty else { return [] }
        if values.count == 1 {
            return [CGPoint(x: w / 2, y: h - values[0] / 100 * h)]
        }
        return values.enumerated().map { i, v in
            CGPoint(x: Double(i) / Double(values.count - 1) * w, y: h - v / 100 * (h - 8) - 4)
        }
    }
}
