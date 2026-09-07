import SwiftUI

enum Stamp {
    private static let short: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func day(_ d: Date) -> String { short.string(from: d).uppercased() }

    static func gap(_ days: Int) -> String {
        days == 1 ? "1 day apart" : "\(days) days apart"
    }
}

struct Plate: View {
    let text: String
    var trailing: String?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(text)
                .plateStyle(2.4, size: 10)
                .foregroundColor(Ink.mute)
                .lineLimit(1)
                .fixedSize()
            Rectangle().fill(Ink.hair).frame(height: 1)
            if let trailing {
                Text(trailing)
                    .plateStyle(1.8, size: 10)
                    .foregroundColor(Ink.mute.opacity(0.7))
            }
        }
    }
}

struct Chip: View {
    let text: String
    let on: Bool
    var tint: Color = Ink.now
    var tap: () -> Void

    var body: some View {
        Button {
            Buzz.tap()
            tap()
        } label: {
            Text(text)
                .plateStyle(1.6, size: 10)
                .foregroundColor(on ? Ink.well : Ink.veil.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Chamfer(cut: 8, corners: .diagonal)
                        .fill(on ? AnyShapeStyle(tint) : AnyShapeStyle(Ink.slab))
                )
                .overlay(
                    Chamfer(cut: 8, corners: .diagonal)
                        .stroke(on ? .clear : Ink.hair, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: on)
    }
}

struct Figure: View {
    let value: String
    let caption: String
    var tint: Color = Ink.veil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(Face.display(32))
                .foregroundColor(tint)
            Text(caption)
                .plateStyle(1.6, size: 9)
                .foregroundColor(Ink.mute)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .slab(cut: 12, corners: [.tl, .br], fill: Ink.slab.opacity(0.7))
    }
}

struct Nothing: View {
    let title: String
    let line: String
    var cta: String?
    var act: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Chamfer(cut: 18, corners: .diagonal)
                .stroke(Ink.hair, style: StrokeStyle(lineWidth: 1, dash: [5, 6]))
                .frame(width: 92, height: 116)
                .overlay(
                    Circle()
                        .fill(Ink.slab)
                        .frame(width: 26, height: 26)
                        .overlay(Circle().stroke(Ink.hair, lineWidth: 1))
                )

            VStack(spacing: 10) {
                Text(title)
                    .font(Face.display(27))
                    .foregroundColor(Ink.veil)
                    .multilineTextAlignment(.center)
                Text(line)
                    .font(Face.body(14))
                    .foregroundColor(Ink.mute)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            if let cta, let act {
                Button(cta, action: act)
                    .buttonStyle(PressIn())
                    .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ToneDot: View {
    let tone: Tone
    var size: CGFloat = 7

    var body: some View {
        Circle()
            .fill(tone.tint)
            .frame(width: size, height: size)
    }
}
