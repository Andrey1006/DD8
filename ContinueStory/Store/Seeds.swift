import Foundation

enum Seeds {
    static func starter() -> [Piece] {
        let day = 86_400.0
        let now = Date()

        var first = Piece(
            id: UUID(),
            opening: "The bakery on Vasin Street burned down on a Tuesday. By Friday the smell was gone, but the queue was still forming at seven every morning. Nobody in it would say what they were waiting for.",
            sealedAt: now.addingTimeInterval(-63 * day),
            ripeAt: now.addingTimeInterval(-31 * day),
            toneAtSeal: .dread,
            spark: "There was a queue, and nobody knew what for."
        )
        first.guess = "something about a shop, I think a fire"
        first.close = "It took the city eleven weeks to admit there had never been a bakery. The permits were for a laundry. The woman who sold bread there had a name nobody could produce a document for, and the queue kept coming anyway, because by then the waiting had become the thing itself. On the last morning somebody brought a folding chair. That is when they knew it was permanent."
        first.closedAt = now.addingTimeInterval(-30 * day)
        first.toneAtClose = .hollow
        first.origin = .demo
        first.drift = Drift.score(first)

        var second = Piece(
            id: UUID(),
            opening: "My grandfather kept a second set of house keys on a nail by the door for someone who never came. When he died we tried them on every lock in the house.",
            sealedAt: now.addingTimeInterval(-40 * day),
            ripeAt: now.addingTimeInterval(-12 * day),
            toneAtSeal: .cold,
            spark: nil
        )
        second.guess = "keys, my grandfather's flat"
        second.close = "None of them fit, which we had expected, and it still felt like being turned away. My mother put them back on the nail before we left. She said the point of a spare key is not the door. It is that you believed, right up to the end, that someone might need to get in."
        second.closedAt = now.addingTimeInterval(-11 * day)
        second.toneAtClose = .tender
        second.origin = .demo
        second.drift = Drift.score(second)

        var ripe = Piece(
            id: UUID(),
            opening: "There is a man on the 6:40 train who reads the same page every morning. I have watched him for a month. He has never once turned it.",
            sealedAt: now.addingTimeInterval(-19 * day),
            ripeAt: now.addingTimeInterval(-90 * 60),
            toneAtSeal: .wry,
            spark: nil
        )
        ripe.origin = .demo

        var waiting = Piece(
            id: UUID(),
            opening: "The building sent a notice about a fire drill on the fourteenth floor. There are twelve floors.",
            sealedAt: now.addingTimeInterval(-9 * day),
            ripeAt: now.addingTimeInterval(6 * day + 4 * 3600),
            toneAtSeal: .absurd,
            spark: "The lift goes down further than the building goes."
        )
        waiting.origin = .demo

        return [first, second, ripe, waiting]
    }
}
