import Foundation

/// Derives celebrated moments from your history. Each milestone is dated to when
/// it actually happened, so the list reads like a timeline of your season. Beyond
/// plain counting milestones, this finds the *character* moments: your first
/// skunk, a flawless night, a dawn-patrol game, the day you finally cracked a
/// rival. Every caption is in the app's voice; a losing record is never shamed.
enum MilestoneEngine {
    private static let gameThresholds = [10, 25, 50, 100, 250, 500, 1000]
    private static let courtThresholds = [3, 5, 10, 25]
    private static let streakThresholds = [3, 5, 10, 15, 20]
    private static let partnerThresholds = [25, 50, 100]
    private static let peopleThresholds = [10, 25, 50]

    /// All achieved milestones, most recent first.
    static func achieved(games: [Game], sessions: [Session]) -> [Milestone] {
        let orderedGames = games.sorted { $0.playedAt < $1.playedAt }
        let playedSessions = sessions
            .filter { !($0.games ?? []).isEmpty }
            .sorted { $0.startedAt < $1.startedAt }
        var result: [Milestone] = []

        result.append(contentsOf: firstsAndCounts(orderedGames))
        result.append(contentsOf: streakMilestones(orderedGames))
        result.append(contentsOf: characterMoments(orderedGames))
        result.append(contentsOf: sessionMoments(playedSessions))
        result.append(contentsOf: courtMilestones(orderedGames))
        result.append(contentsOf: peopleMilestones(orderedGames))
        result.append(contentsOf: partnerMilestones(orderedGames))
        result.append(contentsOf: timeMoments(orderedGames))
        result.append(contentsOf: anniversary(orderedGames))

        return result.sorted { $0.achievedAt > $1.achievedAt }
    }

    // MARK: Firsts and counts

    private static func firstsAndCounts(_ ordered: [Game]) -> [Milestone] {
        var result: [Milestone] = []

        if let first = ordered.first {
            result.append(Milestone(
                id: "debut", headline: "Day one",
                caption: "where it all begins.",
                symbol: "flag.checkered", tint: .neutral, achievedAt: first.playedAt
            ))
        }
        if let firstWin = ordered.first(where: { $0.didWin }) {
            result.append(Milestone(
                id: "first-win", headline: "The first W",
                caption: "the taste that hooks you.",
                symbol: "trophy.fill", tint: .win, achievedAt: firstWin.playedAt
            ))
        }
        for t in gameThresholds where ordered.count >= t {
            result.append(Milestone(
                id: "games-\(t)", headline: "\(t) games",
                caption: gamesCaption(t),
                symbol: "square.stack.3d.up.fill", tint: .neutral, achievedAt: ordered[t - 1].playedAt
            ))
        }
        return result
    }

    private static func gamesCaption(_ t: Int) -> String {
        switch t {
        case 10: return "double digits. look at you."
        case 25: return "a couple dozen memories deep."
        case 50: return "half a hundred, all remembered."
        case 100: return "triple digits. certified obsessed."
        case 250: return "who has the time? you do."
        case 500: return "a paddle with real mileage."
        default: return "a thousand games. a legend, honestly."
        }
    }

    // MARK: Streaks

    private static func streakMilestones(_ ordered: [Game]) -> [Milestone] {
        var result: [Milestone] = []
        var streak = 0
        var reached = Set<Int>()
        for game in ordered {
            streak = game.didWin ? streak + 1 : 0
            for t in streakThresholds where streak == t && !reached.contains(t) {
                reached.insert(t)
                result.append(Milestone(
                    id: "streak-\(t)", headline: "\(t) in a row",
                    caption: streakCaption(t),
                    symbol: "flame.fill", tint: .streak, achievedAt: game.playedAt
                ))
            }
        }
        return result
    }

    private static func streakCaption(_ t: Int) -> String {
        switch t {
        case 3: return "people are starting to notice."
        case 5: return "officially a problem."
        case 10: return "somebody go check on the losers."
        case 15: return "this is just bullying now."
        default: return "please, they have families."
        }
    }

    // MARK: Character moments (the fun ones)

    private static func characterMoments(_ ordered: [Game]) -> [Milestone] {
        var result: [Milestone] = []

        // First skunk: a shutout win.
        if let skunk = ordered.first(where: { $0.didWin && $0.theirScore == 0 && $0.myScore >= 7 }) {
            result.append(Milestone(
                id: "skunk-first", headline: "The Skunk",
                caption: "a shutout. cold blooded.",
                detail: "\(skunk.myScore)-0\(versus(skunk))",
                symbol: "bolt.fill", tint: .special, achievedAt: skunk.playedAt
            ))
        }
        // Five skunks: a habit.
        let skunks = ordered.filter { $0.didWin && $0.theirScore == 0 && $0.myScore >= 7 }
        if skunks.count >= 5 {
            result.append(Milestone(
                id: "skunk-5", headline: "Skunk season",
                caption: "five shutouts. merciless.",
                symbol: "bolt.horizontal.fill", tint: .special, achievedAt: skunks[4].playedAt
            ))
        }
        // First deuce win: won by exactly two, past the target.
        if let deuce = ordered.first(where: { $0.didWin && $0.myScore - $0.theirScore == 2 && $0.myScore >= 12 }) {
            result.append(Milestone(
                id: "deuce-first", headline: "Deuce survivor",
                caption: "won it the hard way.",
                detail: "\(deuce.myScore)-\(deuce.theirScore)",
                symbol: "checkmark.seal.fill", tint: .win, achievedAt: deuce.playedAt
            ))
        }
        // Nemesis slayed: first win over someone who had beaten you three times.
        if let slay = nemesisSlain(ordered) {
            result.append(slay)
        }
        return result
    }

    /// The first time you beat an opponent who had already beaten you 3+ times.
    private static func nemesisSlain(_ ordered: [Game]) -> Milestone? {
        var lossesTo: [UUID: Int] = [:]
        for game in ordered {
            for opp in game.opponents ?? [] where opp.isAlive {
                if game.didWin {
                    if (lossesTo[opp.remoteID] ?? 0) >= 3 {
                        let first = firstName(opp.name)
                        return Milestone(
                            id: "slay-\(opp.remoteID.uuidString)", headline: "White whale, meet harpoon",
                            caption: "you finally got them.",
                            detail: "over \(first)",
                            symbol: "crown.fill", tint: .rivalry, achievedAt: game.playedAt
                        )
                    }
                } else {
                    lossesTo[opp.remoteID, default: 0] += 1
                }
            }
        }
        return nil
    }

    // MARK: Session moments

    private static func sessionMoments(_ sessions: [Session]) -> [Milestone] {
        var result: [Milestone] = []

        // First flawless night: 3+ games, all wins.
        for session in sessions {
            let games = session.gamesInOrder
            guard games.count >= 3, games.allSatisfy({ $0.didWin }) else { continue }
            result.append(Milestone(
                id: "flawless-first", headline: "Flawless night",
                caption: "a clean sweep, start to finish.",
                detail: "\(games.count)-0 on the night",
                symbol: "rosette", tint: .special, achievedAt: session.startedAt
            ))
            break
        }
        // First marathon: 8+ games in one session.
        if let marathon = sessions.first(where: { $0.gamesInOrder.count >= 8 }) {
            let n = marathon.gamesInOrder.count
            result.append(Milestone(
                id: "marathon-first", headline: "Iron paddle",
                caption: "\(n) games in one night. respect.",
                symbol: "infinity", tint: .special, achievedAt: marathon.startedAt
            ))
        }
        // Regular: ten sessions at one court.
        if let regular = regularCourt(sessions) {
            result.append(regular)
        }
        return result
    }

    private static func regularCourt(_ sessions: [Session]) -> Milestone? {
        var counts: [UUID: (name: String, count: Int, date: Date)] = [:]
        for session in sessions {
            guard let court = session.court, court.isAlive else { continue }
            var entry = counts[court.remoteID] ?? (court.name, 0, session.startedAt)
            entry.count += 1
            if entry.count == 10 { entry.date = session.startedAt }
            counts[court.remoteID] = entry
        }
        guard let hit = counts.values.first(where: { $0.count >= 10 }) else { return nil }
        return Milestone(
            id: "regular-court", headline: "Regular",
            caption: "\(hit.name) knows your name.",
            detail: hit.name,
            symbol: "house.fill", tint: .courts, achievedAt: hit.date
        )
    }

    // MARK: Courts, people, partners

    private static func courtMilestones(_ ordered: [Game]) -> [Milestone] {
        let firstPlayed = firstPlayedDatesByCourt(ordered).sorted { $0.value < $1.value }
        var result: [Milestone] = []
        for t in courtThresholds where firstPlayed.count >= t {
            result.append(Milestone(
                id: "courts-\(t)", headline: "\(t) courts",
                caption: courtsCaption(t),
                symbol: "map.fill", tint: .courts, achievedAt: firstPlayed[t - 1].value
            ))
        }
        return result
    }

    private static func courtsCaption(_ t: Int) -> String {
        switch t {
        case 3: return "a proper little circuit."
        case 5: return "you get around."
        case 10: return "have paddle, will travel."
        default: return "the whole map, basically."
        }
    }

    private static func peopleMilestones(_ ordered: [Game]) -> [Milestone] {
        let firstSeen = firstSeenDatesByPlayer(ordered).sorted { $0.value.date < $1.value.date }
        var result: [Milestone] = []
        for t in peopleThresholds where firstSeen.count >= t {
            result.append(Milestone(
                id: "people-\(t)", headline: "\(t) people",
                caption: peopleCaption(t),
                symbol: "person.3.fill", tint: .people, achievedAt: firstSeen[t - 1].value.date
            ))
        }
        return result
    }

    private static func peopleCaption(_ t: Int) -> String {
        switch t {
        case 10: return "a whole crew now."
        case 25: return "you basically know everybody."
        default: return "the mayor of the courts."
        }
    }

    private static func partnerMilestones(_ ordered: [Game]) -> [Milestone] {
        var byPartner: [UUID: (name: String, games: [Game])] = [:]
        for game in ordered {
            guard let partner = game.myPartner, partner.isAlive else { continue }
            byPartner[partner.remoteID, default: (partner.name, [])].games.append(game)
        }
        var result: [Milestone] = []
        for (id, entry) in byPartner {
            let first = firstName(entry.name)
            for t in partnerThresholds where entry.games.count >= t {
                result.append(Milestone(
                    id: "partner-\(id.uuidString)-\(t)", headline: "\(t) with \(first)",
                    caption: "chemistry, on the record.",
                    symbol: "heart.fill", tint: .win, achievedAt: entry.games[t - 1].playedAt
                ))
            }
        }
        return result
    }

    // MARK: Time-of-day moments

    private static func timeMoments(_ ordered: [Game]) -> [Milestone] {
        var result: [Milestone] = []
        let calendar = Calendar.current

        if let dawn = ordered.first(where: { calendar.component(.hour, from: $0.playedAt) < 7 }) {
            result.append(Milestone(
                id: "dawn", headline: "Dawn patrol",
                caption: "before the coffee, even.",
                symbol: "sunrise.fill", tint: .neutral, achievedAt: dawn.playedAt
            ))
        }
        if let night = ordered.first(where: { calendar.component(.hour, from: $0.playedAt) >= 22 }) {
            result.append(Milestone(
                id: "night", headline: "Night owl",
                caption: "the courts were all yours.",
                symbol: "moon.stars.fill", tint: .neutral, achievedAt: night.playedAt
            ))
        }
        // The full set: a morning, an afternoon, and an evening game logged.
        var seen = Set<Int>()
        for game in ordered {
            let hour = calendar.component(.hour, from: game.playedAt)
            let bucket = hour < 12 ? 0 : (hour < 17 ? 1 : 2)
            seen.insert(bucket)
            if seen.count == 3 {
                result.append(Milestone(
                    id: "full-set", headline: "The full set",
                    caption: "morning, noon, and night.",
                    symbol: "clock.fill", tint: .neutral, achievedAt: game.playedAt
                ))
                break
            }
        }
        return result
    }

    // MARK: Anniversary

    private static func anniversary(_ ordered: [Game]) -> [Milestone] {
        guard let first = ordered.first else { return [] }
        guard let oneYear = Calendar.current.date(byAdding: .year, value: 1, to: first.playedAt) else { return [] }
        // Only celebrate once the year has actually elapsed (latest game is past it).
        guard let last = ordered.last, last.playedAt >= oneYear else { return [] }
        return [Milestone(
            id: "anniversary-1", headline: "One year in",
            caption: "and only getting started.",
            symbol: "party.popper.fill", tint: .special, achievedAt: oneYear
        )]
    }

    // MARK: Helpers

    private static func firstPlayedDatesByCourt(_ ordered: [Game]) -> [UUID: Date] {
        var dates: [UUID: Date] = [:]
        for game in ordered {
            guard let court = game.session?.court, court.isAlive else { continue }
            if dates[court.remoteID] == nil { dates[court.remoteID] = game.playedAt }
        }
        return dates
    }

    private static func firstSeenDatesByPlayer(_ ordered: [Game]) -> [UUID: (name: String, date: Date)] {
        var seen: [UUID: (String, Date)] = [:]
        for game in ordered {
            var players: [Player] = []
            if let p = game.myPartner { players.append(p) }
            players.append(contentsOf: game.opponents ?? [])
            for player in players where player.isAlive {
                if seen[player.remoteID] == nil { seen[player.remoteID] = (player.name, game.playedAt) }
            }
        }
        return seen
    }

    private static func versus(_ game: Game) -> String {
        let names = (game.opponents ?? []).filter { $0.isAlive }.map { firstName($0.name) }
        guard !names.isEmpty else { return "" }
        return " over " + names.joined(separator: " & ")
    }

    private static func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
