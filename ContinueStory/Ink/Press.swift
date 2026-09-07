import SwiftUI

struct PressIn: ButtonStyle {
    var tint: Color = Ink.now
    var solid = false

    func makeBody(configuration: Configuration) -> some View {
        let down = configuration.isPressed
        configuration.label
            .font(Face.plate(11, .bold))
            .tracking(1.6)
            .textCase(.uppercase)
            .foregroundColor(solid ? Ink.well : tint)
            .padding(.horizontal, 22)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(
                Chamfer(cut: 12, corners: .diagonal)
                    .fill(solid ? AnyShapeStyle(tint) : AnyShapeStyle(tint.opacity(down ? 0.16 : 0.07)))
            )
            .overlay(
                Chamfer(cut: 12, corners: .diagonal)
                    .stroke(tint.opacity(solid ? 0 : 0.45), lineWidth: 1)
            )
            .scaleEffect(down ? 0.965 : 1)
            .brightness(down && solid ? -0.08 : 0)
            .animation(.spring(response: 0.26, dampingFraction: 0.62), value: down)
    }
}

struct Ghost: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Face.plate(10, .semibold))
            .tracking(1.6)
            .textCase(.uppercase)
            .foregroundColor(Ink.mute)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

enum Buzz {
    static func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func snap() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
