import SwiftUI

struct Rng {
    private var s: UInt64

    init(_ seed: UInt64) { s = seed == 0 ? 0x9E3779B97F4A7C15 : seed }

    mutating func next() -> UInt64 {
        s &+= 0x9E3779B97F4A7C15
        var z = s
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func unit() -> Double { Double(next() % 10_000) / 10_000 }

    mutating func between(_ a: Double, _ b: Double) -> Double { a + (b - a) * unit() }
}

struct Cover: View {
    let piece: Piece

    var body: some View {
        Canvas { ctx, size in
            var rng = Rng(seed)
            let w = size.width, h = size.height
            let hot = piece.toneAtSeal.tint
            let cool = (piece.toneAtClose ?? piece.toneAtSeal).tint

            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Ink.well))
            ctx.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(
                    Gradient(colors: [hot.opacity(0.30), Ink.night.opacity(0.1), cool.opacity(0.22)]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: w, y: h)
                )
            )

            let drift = Double(piece.drift ?? 0) / 100
            let r = w * 0.29
            let spread = w * (0.06 + drift * 0.40)
            let tilt = rng.between(-0.28, 0.28)
            let cy = h * 0.44 + rng.between(-6, 6)

            let a = CGPoint(x: w / 2 - spread * cos(tilt), y: cy - spread * sin(tilt) * 0.5)
            let b = CGPoint(x: w / 2 + spread * cos(tilt), y: cy + spread * sin(tilt) * 0.5)

            ctx.fill(disc(at: a, r: r), with: .color(Ink.past.opacity(0.85)))
            ctx.blendMode = .plusLighter
            ctx.fill(disc(at: b, r: r), with: .color(Ink.now.opacity(0.72)))
            ctx.blendMode = .normal

            let weeks = min(9, max(1, piece.gapDays / 7))
            let step = w / 12
            for i in 0..<weeks {
                let x = step * 1.5 + Double(i) * step * 0.8
                var tick = Path()
                tick.move(to: CGPoint(x: x, y: h - 13))
                tick.addLine(to: CGPoint(x: x, y: h - 6))
                ctx.stroke(tick, with: .color(Ink.veil.opacity(0.55)), lineWidth: 1.5)
            }

            if piece.cracked {
                var slash = Path()
                slash.move(to: CGPoint(x: w * 0.1, y: h * 0.12))
                slash.addLine(to: CGPoint(x: w * 0.92, y: h * 0.3))
                ctx.stroke(slash, with: .color(Ink.veil.opacity(0.75)), lineWidth: 1.5)
            }
        }
        .background(Ink.well)
        .clipShape(Chamfer(cut: 10, corners: .diagonal))
        .overlay(Chamfer(cut: 10, corners: .diagonal).stroke(Ink.hair, lineWidth: 1))
    }

    private func disc(at c: CGPoint, r: Double) -> Path {
        Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
    }

    private var seed: UInt64 {
        let u = piece.id.uuid
        return [u.0, u.1, u.2, u.3, u.4, u.5, u.6, u.7]
            .reduce(UInt64(0)) { ($0 &<< 8) | UInt64($1) }
    }
}
