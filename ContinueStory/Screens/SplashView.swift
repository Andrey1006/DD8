import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void = {}
    var autoDismiss: Bool = true

    @State private var drawProgress: CGFloat = 0
    @State private var auraScale: CGFloat = 0.6
    @State private var auraOpacity: Double = 0
    @State private var coreGlow: Double = 0
    @State private var ringSpin: Double = 0
    @State private var particlesLive = false
    @State private var fadeOut = false

    private let duration: TimeInterval = 3

    var body: some View {
        ZStack {
            Backdrop(glow: Ink.now)

            RadialGradient(
                colors: [Ink.now.opacity(0.14), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 320
            )
            .scaleEffect(auraScale)
            .opacity(auraOpacity)
            .ignoresSafeArea()

            PulseField(isActive: particlesLive)
                .allowsHitTesting(false)

            emblem

            DustField(isActive: particlesLive)
                .allowsHitTesting(false)

            VStack {
                Spacer()
                meter
                mark
            }
            .padding(.bottom, 54)
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear(perform: runAnimation)
    }

    private var emblem: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: drawProgress * 0.42)
                .stroke(
                    AngularGradient(colors: [Ink.past.opacity(0), Ink.past], center: .center),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 176, height: 176)
                .rotationEffect(.degrees(ringSpin))

            Circle()
                .trim(from: 0, to: drawProgress * 0.42)
                .stroke(
                    AngularGradient(colors: [Ink.now.opacity(0), Ink.now], center: .center),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 134, height: 134)
                .rotationEffect(.degrees(-ringSpin * 1.4))

            Circle()
                .stroke(Ink.hair.opacity(0.55), lineWidth: 1)
                .frame(width: 210, height: 210)
                .scaleEffect(auraScale)
                .opacity(auraOpacity)

            Chamfer(cut: 18, corners: .all)
                .fill(Ink.bridge)
                .frame(width: 62, height: 62)
                .rotationEffect(.degrees(45 + ringSpin * 0.3))
                .scaleEffect(1 + coreGlow * 0.06)

            Chamfer(cut: 18, corners: .all)
                .fill(Ink.veil)
                .frame(width: 62, height: 62)
                .rotationEffect(.degrees(45 + ringSpin * 0.3))
                .scaleEffect(1 + coreGlow * 0.06)
                .opacity(coreGlow * 0.35)
                .blur(radius: 7)

            Chamfer(cut: 10, corners: .all)
                .stroke(Ink.veil.opacity(0.7), lineWidth: 1)
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(-ringSpin * 0.6))
        }
        .shadow(color: Ink.now.opacity(0.35), radius: 18)
    }

    private var meter: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Ink.hair.opacity(0.7))
                .frame(height: 2)

            Capsule()
                .fill(Ink.bridge)
                .frame(height: 2)
                .scaleEffect(x: drawProgress, anchor: .leading)
        }
        .frame(width: 128)
        .opacity(auraOpacity)
    }

    private var mark: some View {
        Text("Loading")
            .plateStyle(3.2, size: 9)
            .foregroundColor(Ink.mute)
            .padding(.top, 16)
            .opacity(auraOpacity)
    }

    private func runAnimation() {
        withAnimation(.easeInOut(duration: 1.6)) {
            drawProgress = 1
        }
        withAnimation(.easeOut(duration: 1.2)) {
            auraOpacity = 1
            auraScale = 1.15
        }
        withAnimation(.easeInOut(duration: 1.4).delay(0.6).repeatForever(autoreverses: true)) {
            coreGlow = 1
        }
        withAnimation(.linear(duration: duration * 2).repeatForever(autoreverses: false)) {
            ringSpin = 360
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            particlesLive = true
        }

        guard autoDismiss else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.5) {
            withAnimation(.easeIn(duration: 0.5)) {
                fadeOut = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onFinished()
        }
    }
}

private struct PulseField: View {
    var isActive: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    let cycle = CGFloat((t * 0.42 + Double(i) / 3).truncatingRemainder(dividingBy: 1))
                    Chamfer(cut: 26, corners: .all)
                        .stroke(Ink.now.opacity(Double(1 - cycle) * 0.28), lineWidth: 1)
                        .frame(width: 128 + cycle * 240, height: 128 + cycle * 240)
                        .rotationEffect(.degrees(45 + Double(cycle) * 24))
                }
            }
            .opacity(isActive ? 1 : 0)
        }
    }
}

private struct DustField: View {
    var isActive: Bool

    private let seeds: [Mote] = (0..<30).map { _ in Mote.random() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                for mote in seeds {
                    let cycle = (t * mote.speed + mote.phase).truncatingRemainder(dividingBy: 1)
                    let y = size.height * (1.08 - cycle * 1.2)
                    let sway = sin(t * mote.wobble + mote.phase * 9) * 16
                    let x = size.width * mote.lane + sway
                    let fade = sin(cycle * .pi)
                    let r = mote.size * (0.6 + fade * 0.7)

                    var dot = Path()
                    dot.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
                    context.fill(
                        dot,
                        with: .color((mote.warm ? Ink.past : Ink.now).opacity(isActive ? Double(fade) * 0.5 : 0))
                    )
                }
            }
            .blendMode(.plusLighter)
        }
    }

    private struct Mote {
        let lane: CGFloat
        let phase: CGFloat
        let speed: CGFloat
        let wobble: CGFloat
        let size: CGFloat
        let warm: Bool

        static func random() -> Mote {
            Mote(
                lane: .random(in: 0.05...0.95),
                phase: .random(in: 0...1),
                speed: .random(in: 0.12...0.34),
                wobble: .random(in: 0.6...1.8),
                size: .random(in: 1.2...3.2),
                warm: .random()
            )
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
