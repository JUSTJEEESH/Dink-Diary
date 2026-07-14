import Foundation

/// The app's sense of humor, in one place. Warm, dry, a little unhinged; never
/// mean, never coaching. Losses are rivalries, never failures.
///
/// Selection is deterministic: every picker takes a stable `seed` (usually a
/// hash of an id or a value) so the same context always shows the same line.
/// That keeps SwiftUI re-renders from reshuffling copy under the reader.
///
/// Brand rules enforced here: no em dashes; commas and semicolons only.
enum Quips {

    /// Deterministic pick. Same options + same seed, same line, every render.
    private static func pick(_ options: [String], seed: Int) -> String {
        guard !options.isEmpty else { return "" }
        return options[abs(seed) % options.count]
    }

    /// A stable integer seed from a string (a remoteID, a name). Simple FNV-1a,
    /// so it does not depend on Swift's per-launch String hashing.
    static func seed(_ string: String) -> Int {
        var hash = 0x811c_9dc5
        for byte in string.utf8 {
            hash = (hash ^ Int(byte)) &* 0x0100_0193
        }
        return hash & 0x7fff_ffff
    }

    // MARK: Empty timeline

    /// The "no games yet" nudge. Seeded by the calendar day so it changes daily
    /// but never mid-scroll.
    static func emptyTimeline(daySeed: Int) -> (title: String, line: String) {
        let pairs: [(String, String)] = [
            ("No games yet.", "Go find a fourth."),
            ("Nothing here.", "The kitchen is calling."),
            ("A blank season.", "Every legend starts 0-0."),
            ("Quiet in here.", "Your paddle is getting bored."),
            ("No dinks logged.", "This is the part before the montage."),
            ("Empty diary.", "Somebody has to be the fourth. Might as well be you."),
        ]
        let choice = pairs[abs(daySeed) % pairs.count]
        return choice
    }

    // MARK: Streaks

    /// Scales with how hot you are. Seeded by count so it is stable per streak.
    static func streak(count: Int) -> String {
        switch count {
        case ..<2: return ""
        case 2: return "Two straight. A pattern forms."
        case 3: return "Three in a row. People are noticing."
        case 4: return "Four straight. Save some for the rest of us."
        case 5: return "Five. You are officially a problem."
        case 6...8: return "\(count) straight. The kitchen is yours."
        case 9...11: return "\(count) in a row. Somebody check on the losers."
        default: return "\(count) straight. This is just bullying now."
        }
    }

    // MARK: Score tags (easter eggs on the game row)

    /// A tiny tag for a memorable final score. Returns nil for ordinary games so
    /// the row stays clean; only special results earn a word.
    static func scoreTag(myScore: Int, theirScore: Int) -> String? {
        let hi = max(myScore, theirScore)
        let lo = min(myScore, theirScore)
        let margin = hi - lo
        let iWon = myScore > theirScore

        // A shutout, either direction. The oldest word in the sport.
        if lo == 0 && hi >= 7 {
            return iWon ? "Skunk" : "Skunked"
        }
        // A deuce war: won by exactly two, up past the target.
        if margin == 2 && hi >= 12 {
            return "Barn burner"
        }
        // A statement blowout.
        if margin >= 9 && hi >= 11 {
            return iWon ? "Statement made" : "We do not talk about it"
        }
        // A one-rally season, decided at the wire.
        if margin == 2 && hi == 11 && lo == 9 {
            return "Down to the wire"
        }
        return nil
    }

    // MARK: Loss framing (rivalry, never failure)

    /// Reframes a losing record. Seeded so a given record reads the same.
    static func rivalryLine(seed: Int) -> String {
        pick([
            "One day.",
            "A rivalry with room to grow.",
            "The comeback is still loading.",
            "History is written by whoever plays next week.",
            "You are building a great origin story.",
        ], seed: seed)
    }

    // MARK: On this day

    static func onThisDay(seed: Int) -> String {
        pick([
            "Remember this one?",
            "A year wiser, same paddle.",
            "This still counts.",
            "Past you says hello.",
        ], seed: seed)
    }

    // MARK: Kitchen secret (Settings easter egg payoff)

    /// The lines revealed by the hidden tap counter in Settings, in order.
    static let kitchenSecret: [String] = [
        "You found the kitchen.",
        "No volleying in here.",
        "Seriously, that is the rule.",
        "Okay you can stay. Nice dinks.",
    ]
}
