import Foundation

/// Warm, auto-written narrative about the people in your pickleball life: your
/// chemistry as partners, your rivalry as opponents, and a sense of momentum
/// ("you flipped it this month"). This is memory, not analysis. A losing record
/// is always a rivalry, never a failure. Brand rules: no em dashes, no coaching
/// language. Everything is derived from the games passed in; nothing is stored.
struct Storyline: Identifiable {
    enum Tone { case chemistry, rivalry, even, fresh }

    let id: String
    let headline: String
    let body: String
    let tone: Tone
    /// The person this is about, so a card can navigate to them.
    let subjectID: UUID?
}

enum StorylineEngine {
    private static let recentWindowDays = 30
    private static let staleDays = 60

    // MARK: Per-person narrative (the detail page)

    /// A two-to-four sentence story about one person, adapting to whether they
    /// are mostly your partner, mostly your rival, or both.
    static func narrative(for player: Player, in games: [Game], now: Date) -> Storyline {
        let first = firstName(player.name)
        let together = StatsEngine.record(withPartner: player, in: games)
        let against = StatsEngine.record(against: player, in: games)
        let partnerTotal = together.wins + together.losses
        let rivalTotal = against.wins + against.losses

        guard partnerTotal + rivalTotal > 0 else {
            return Storyline(
                id: player.remoteID.uuidString,
                headline: "A blank page",
                body: "You have not shared a court with \(first) yet. Every good rivalry starts with one game.",
                tone: .fresh,
                subjectID: player.remoteID
            )
        }

        let recent = games.filter { $0.playedAt >= now.addingTimeInterval(TimeInterval(-recentWindowDays * 86_400)) }
        var parts: [String] = []
        let tone: Storyline.Tone

        if partnerTotal >= rivalTotal {
            // Primarily your partner.
            tone = together.wins > together.losses ? .chemistry : (together.wins == together.losses ? .even : .rivalry)
            parts.append("You and \(first) are \(together.wins)-\(together.losses) as a team.")
            if together.wins > together.losses {
                parts.append("The chemistry is real.")
            } else if together.wins == together.losses {
                parts.append("Even every time out, and always a good time.")
            } else {
                parts.append("Still finding your rhythm together, which is its own kind of fun.")
            }
            let recentTogether = StatsEngine.record(withPartner: player, in: recent)
            if recentTogether.wins + recentTogether.losses >= 2, recentTogether.wins > recentTogether.losses, together.losses > 0 {
                parts.append("Lately you are \(recentTogether.wins)-\(recentTogether.losses) and nobody wants that draw.")
            }
            if rivalTotal > 0 {
                parts.append("On opposite sides, it is \(against.wins)-\(against.losses).")
            }
        } else {
            // Primarily your rival. against.losses are their wins over you.
            let theirWins = against.losses
            let myWins = against.wins
            tone = .rivalry
            if theirWins > myWins {
                parts.append("\(first) leads your rivalry \(theirWins)-\(myWins). A rivalry, not a verdict.")
            } else if myWins > theirWins {
                parts.append("You lead the rivalry with \(first), \(myWins)-\(theirWins). Enjoy it.")
            } else {
                parts.append("You and \(first) are dead even, \(myWins)-\(theirWins), the most dangerous kind.")
            }
            let recentAgainst = StatsEngine.record(against: player, in: recent)
            if recentAgainst.wins + recentAgainst.losses >= 2, theirWins > myWins, recentAgainst.wins > recentAgainst.losses {
                parts.append("But you flipped it lately: \(recentAgainst.wins)-\(recentAgainst.losses) this month.")
            }
            if partnerTotal > 0 {
                parts.append("Team up and you are \(together.wins)-\(together.losses); you know each other's game cold.")
            }
        }

        if let last = StatsEngine.lastPlayed(with: player, in: games) {
            let days = Calendar.current.dateComponents([.day], from: last, to: now).day ?? 0
            if days > staleDays {
                parts.append("It has been a while. Your move.")
            }
        }

        return Storyline(
            id: player.remoteID.uuidString,
            headline: headline(for: tone),
            body: parts.joined(separator: " "),
            tone: tone,
            subjectID: player.remoteID
        )
    }

    // MARK: Season storylines (the Insights tab)

    /// The most interesting one-liners about your season's people, most
    /// compelling first: a recent flip, your rivalry, your best chemistry.
    static func seasonStorylines(in games: [Game], now: Date, limit: Int = 2) -> [Storyline] {
        var result: [Storyline] = []
        var usedSubjects = Set<UUID>()

        // A flip: someone who led you overall but whom you have beaten lately.
        if let flip = flipStoryline(in: games, now: now) {
            result.append(flip)
            if let id = flip.subjectID { usedSubjects.insert(id) }
        }

        // Your rivalry.
        if let nemesis = StatsEngine.nemesis(in: games, minGames: 3), !usedSubjects.contains(nemesis.player.remoteID) {
            let first = firstName(nemesis.player.name)
            result.append(Storyline(
                id: "rivalry-\(nemesis.player.remoteID.uuidString)",
                headline: "Your rivalry",
                body: "\(first) leads you \(nemesis.losses)-\(nemesis.wins). We do not talk about it. One day.",
                tone: .rivalry,
                subjectID: nemesis.player.remoteID
            ))
            usedSubjects.insert(nemesis.player.remoteID)
        }

        // Your best chemistry.
        if let best = StatsEngine.chemistryRanking(in: games, minGames: 2).first,
           best.wins >= best.losses, !usedSubjects.contains(best.player.remoteID) {
            let first = firstName(best.player.name)
            result.append(Storyline(
                id: "chemistry-\(best.player.remoteID.uuidString)",
                headline: "Your person",
                body: "You and \(first) are \(best.wins)-\(best.losses) together. Chemistry, certified.",
                tone: .chemistry,
                subjectID: best.player.remoteID
            ))
            usedSubjects.insert(best.player.remoteID)
        }

        return Array(result.prefix(limit))
    }

    /// Finds the most striking momentum swing against an opponent: behind
    /// overall, ahead in the recent window.
    private static func flipStoryline(in games: [Game], now: Date) -> Storyline? {
        let recent = games.filter { $0.playedAt >= now.addingTimeInterval(TimeInterval(-recentWindowDays * 86_400)) }
        var best: (player: Player, recentWins: Int, recentLosses: Int, deficit: Int)?

        for player in uniqueOpponents(in: games) {
            let overall = StatsEngine.record(against: player, in: games)
            let overallDeficit = overall.losses - overall.wins   // positive = they lead overall
            guard overallDeficit > 0 else { continue }
            let r = StatsEngine.record(against: player, in: recent)
            guard r.wins + r.losses >= 2, r.wins > r.losses else { continue }
            if best == nil || overallDeficit > best!.deficit {
                best = (player, r.wins, r.losses, overallDeficit)
            }
        }

        guard let flip = best else { return nil }
        let first = firstName(flip.player.name)
        return Storyline(
            id: "flip-\(flip.player.remoteID.uuidString)",
            headline: "The flip",
            body: "You finally cracked \(first) this month, \(flip.recentWins)-\(flip.recentLosses), after starting behind. The comeback is real.",
            tone: .chemistry,
            subjectID: flip.player.remoteID
        )
    }

    // MARK: Helpers

    private static func headline(for tone: Storyline.Tone) -> String {
        switch tone {
        case .chemistry: return "Your chemistry"
        case .rivalry: return "Your rivalry"
        case .even: return "Neck and neck"
        case .fresh: return "A blank page"
        }
    }

    private static func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    private static func uniqueOpponents(in games: [Game]) -> [Player] {
        var seen = Set<UUID>()
        var result: [Player] = []
        for game in games {
            for opponent in game.opponents ?? [] where opponent.isAlive && !seen.contains(opponent.remoteID) {
                seen.insert(opponent.remoteID)
                result.append(opponent)
            }
        }
        return result
    }
}
