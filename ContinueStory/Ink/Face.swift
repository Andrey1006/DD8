import SwiftUI

enum Face {
    static func display(_ size: CGFloat, _ weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }

    static func plate(_ size: CGFloat = 10, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }

    static func body(_ size: CGFloat = 15, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func story(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular)
    }
}

extension View {
    func plateStyle(_ tracking: CGFloat = 1.8, size: CGFloat = 10) -> some View {
        font(Face.plate(size))
            .tracking(tracking)
            .textCase(.uppercase)
    }
}
