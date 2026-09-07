import Foundation

struct Spark: Identifiable, Equatable {
    let id: Int
    let text: String
    let tones: Set<Tone>
}

enum Sparks {
    static func forToday(_ tones: [Tone], salt: Int = 0) -> Spark {
        let wanted = Set(tones)
        let pool = deck.filter { !$0.tones.isDisjoint(with: wanted) }
        let bag = pool.isEmpty ? deck : pool
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return bag[abs(day &+ salt &* 7) % bag.count]
    }

    static let deck: [Spark] = [
        Spark(id: 1, text: "The last person to leave the building did not lock the door.", tones: [.dread, .cold]),
        Spark(id: 2, text: "She kept the receipt for something she never bought.", tones: [.wry, .hollow]),
        Spark(id: 3, text: "The dog came back wearing a different collar.", tones: [.dread, .absurd]),
        Spark(id: 4, text: "He learned the song before he learned what it meant.", tones: [.tender, .luminous]),
        Spark(id: 5, text: "There was a queue, and nobody knew what for.", tones: [.absurd, .wry]),
        Spark(id: 6, text: "The neighbour's window has been open since March.", tones: [.dread, .hollow]),
        Spark(id: 7, text: "They agreed to meet at the place that closed years ago.", tones: [.tender, .hollow]),
        Spark(id: 8, text: "Every clock in the house is four minutes fast, on purpose.", tones: [.cold, .wry]),
        Spark(id: 9, text: "The letter was addressed to the house, not to anyone in it.", tones: [.dread, .cold]),
        Spark(id: 10, text: "He started counting stairs and could not stop.", tones: [.feverish, .absurd]),
        Spark(id: 11, text: "The sea gave back one shoe, then the other, a week later.", tones: [.luminous, .dread]),
        Spark(id: 12, text: "She told the truth in a language he did not speak.", tones: [.tender, .cold]),
        Spark(id: 13, text: "The fire alarm goes off at 3:14 every night. Only theirs.", tones: [.feverish, .dread]),
        Spark(id: 14, text: "A man is selling maps of a city that has not been built.", tones: [.absurd, .luminous]),
        Spark(id: 15, text: "The photograph has one more person in it than he remembers.", tones: [.dread, .hollow]),
        Spark(id: 16, text: "They kept the bed made for eleven years.", tones: [.tender, .hollow]),
        Spark(id: 17, text: "Someone has been watering the plants in the empty flat.", tones: [.dread, .tender]),
        Spark(id: 18, text: "He was told the meeting would explain everything.", tones: [.cold, .absurd]),
        Spark(id: 19, text: "The train stops at a station that is not on the line.", tones: [.absurd, .dread]),
        Spark(id: 20, text: "She practises her own name until it sounds like a stranger's.", tones: [.hollow, .feverish]),
        Spark(id: 21, text: "The recipe ends with an instruction nobody can follow.", tones: [.wry, .absurd]),
        Spark(id: 22, text: "Light comes through the wall where no window is.", tones: [.luminous, .dread]),
        Spark(id: 23, text: "He apologised before anything happened.", tones: [.dread, .wry]),
        Spark(id: 24, text: "The baby laughs at the corner of the ceiling.", tones: [.dread, .tender]),
        Spark(id: 25, text: "They found the second key, and it fits nothing.", tones: [.cold, .hollow]),
        Spark(id: 26, text: "In the village, everyone is early for everything.", tones: [.absurd, .cold]),
        Spark(id: 27, text: "The radio only plays weather for a country far away.", tones: [.hollow, .luminous]),
        Spark(id: 28, text: "She wrote the ending first and lost the rest.", tones: [.wry, .feverish]),
        Spark(id: 29, text: "He is the only one who finds the joke funny, and he is right.", tones: [.wry, .absurd]),
        Spark(id: 30, text: "The garden has been growing towards the house.", tones: [.dread, .luminous]),
        Spark(id: 31, text: "Nobody has said his name out loud in two years.", tones: [.hollow, .cold]),
        Spark(id: 32, text: "The lift goes down further than the building goes.", tones: [.dread, .absurd]),
        Spark(id: 33, text: "They swapped coats in the rain and never swapped back.", tones: [.tender, .wry]),
        Spark(id: 34, text: "A woman waits at arrivals holding a blank sign.", tones: [.hollow, .luminous]),
        Spark(id: 35, text: "The fever broke and took a memory with it.", tones: [.feverish, .tender]),
        Spark(id: 36, text: "He kept working after the shop was sold.", tones: [.cold, .hollow])
    ]
}
