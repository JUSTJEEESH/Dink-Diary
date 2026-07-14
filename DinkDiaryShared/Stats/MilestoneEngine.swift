import Foundation

/// Derives celebrated moments from your history. Each milestone is dated to when
/// it actually happened, so the list reads like a timeline of your season.
enum MilestoneEngine {
    private static let gameThresholds = [10, 25, 50, 100, 250, 500, 1000]
    private static let sessionThresholds = [10, 25, 50, 100]
    private static let courtThresholds = [3, 5, 10, 25]
    private static let streakThresholds = [3, 5, 10, 15, 20]
    private static let partnerThresholds = [25, 50, 100]
    private static let peopleThresholds = [10, 25, 50]

    /// All achieved milestones, most recent first.
    static func achieved(games: [Game], sessions: [Session]) -> [Milestone] {
        let orderedGames = games.sorted { $0.playedAt < $1.playedAt }
        var result: [Milestone] = []

        // Games played
        for t in gameThresholds where orderedGames.count >= t {
            result.append(Milestone(
                id: "games-\(t)", kind: .games,
                title: "\(t) games", subtitle: "logged and remembered",
                symbol: "number", achievedAt: orderedGames[t - 1].playedAt
            ))
        }

        // Sessions (with games), by start date
        let playedSessions = sessions
            .filter { !($0.games ?? []).isEmpty }
            .sorted { $0.startedAt < $1.startedAt }
        for t in sessionThresholds where playedSessions.count >= t {
            result.append(Milestone(
                id: "sessions-\(t)", kind: .sessions,
                title: "\(t) sessions", subtitle: "nights on the court",
                symbol: "calendar", achievedAt: playedSessions[t - 1].startedAt
            ))
        }

        // Courts, ordered by first time played
        let courtFirstPlayed = firstPlayedDatesByCourt(orderedGames)
        let courtsInOrder = courtFirstPlayed.sorted { $0.value < $1.value }
        for t in courtThresholds where courtsInOrder.count >= t {
            result.append(Milestone(
                id: "courts-\(t)", kind: .courts,
                title: "\(t) courts", subtitle: "places you've played",
                symbol: "mappin.and.ellipse", achievedAt: courtsInOrder[t - 1].value
            ))
        }

        // Longest win streak: first date each threshold was reached
        var streak = 0
        var reached = Set<Int>()
        for game in orderedGames {
            streak = game.didWin ? streak + 1 : 0
            for t in streakThresholds where streak == t && !reached.contains(t) {
                reached.insert(t)
                result.append(Milestone(
                    id: "streak-\(t)", kind: .streak,
                    title: "\(t) in a row", subtitle: "you were the problem",
                    symbol: "flame.fill", achievedAt: game.playedAt
                ))
            }
        }

        // Games with a partner
        result.append(contentsOf: partnerMilestones(orderedGames))

        // People played with or against
        let peopleFirstSeen = firstSeenDatesByPlayer(orderedGames)
        let peopleInOrder = peopleFirstSeen.sorted { $0.value.date < $1.value.date }
        for t in peopleThresholds where peopleInOrder.count >= t {
            result.append(Milestone(
                id: "people-\(t)", kind: .people,
                title: "\(t) people", subtitle: "your pickleball world",
                symbol: "person.2.fill", achievedAt: peopleInOrder[t - 1].value.date
            ))
        }

        return result.sorted { $0.achievedAt > $1.achievedAt }
    }

    private static func firstPlayedDatesByCourt(_ orderedGames: [Game]) -> [UUID: Date] {
        var dates: [UUID: Date] = [:]
        for game in orderedGames {
            guard let court = game.session?.court, court.isAlive else { continue }
            if dates[court.remoteID] == nil { dates[court.remoteID] = game.playedAt }
        }
        return dates
    }

    private static func firstSeenDatesByPlayer(_ orderedGames: [Game]) -> [UUID: (name: String, date: Date)] {
        var seen: [UUID: (String, Date)] = [:]
        for game in orderedGames {
            var players: [Player] = []
            if let p = game.myPartner { players.append(p) }
            players.append(contentsOf: game.opponents ?? [])
            for player in players where player.isAlive {
                if seen[player.remoteID] == nil { seen[player.remoteID] = (player.name, game.playedAt) }
            }
        }
        return seen
    }

    private static func partnerMilestones(_ orderedGames: [Game]) -> [Milestone] {
        var byPartner: [UUID: (name: String, games: [Game])] = [:]
        for game in orderedGames {
            guard let partner = game.myPartner, partner.isAlive else { continue }
            byPartner[partner.remoteID, default: (partner.name, [])].games.append(game)
        }
        var result: [Milestone] = []
        for (id, entry) in byPartner {
            let first = entry.name.split(separator: " ").first.map(String.init) ?? entry.name
            for t in partnerThresholds where entry.games.count >= t {
                result.append(Milestone(
                    id: "partner-\(id.uuidString)-\(t)", kind: .partner,
                    title: "\(t) with \(first)", subtitle: "chemistry, on record",
                    symbol: "figure.2", achievedAt: entry.games[t - 1].playedAt
                ))
            }
        }
        return result
    }
}
