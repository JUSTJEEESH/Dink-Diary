import Foundation

/// The numbers behind Year in Review. Computed for the current year, or all-time
/// if this year is still empty, so the recap always has something to say.
struct SeasonStats {
    let periodLabel: String
    let gamesPlayed: Int
    let sessionsPlayed: Int
    let wins: Int
    let losses: Int
    let topPartnerName: String?
    let topPartnerRecord: (wins: Int, losses: Int)?
    let nemesisName: String?
    let nemesisRecord: (wins: Int, losses: Int)?
    let topCourtName: String?
    let topCourtSessions: Int
    let longestStreak: Int
    let totalMinutes: Int
    let totalCalories: Int
    let pointsScored: Int
    let peopleCount: Int

    var hasData: Bool { gamesPlayed > 0 }
}

enum SeasonRecapEngine {
    static func currentStats(games: [Game], sessions: [Session], now: Date) -> SeasonStats {
        let year = Calendar.current.component(.year, from: now)
        let thisYear = stats(label: "\(year)", games: gamesIn(year: year, games), sessions: sessionsIn(year: year, sessions))
        if thisYear.hasData { return thisYear }
        return stats(label: "All time", games: games, sessions: sessions.filter { !($0.games ?? []).isEmpty })
    }

    private static func gamesIn(year: Int, _ games: [Game]) -> [Game] {
        games.filter { Calendar.current.component(.year, from: $0.playedAt) == year }
    }
    private static func sessionsIn(year: Int, _ sessions: [Session]) -> [Session] {
        sessions.filter { !($0.games ?? []).isEmpty && Calendar.current.component(.year, from: $0.startedAt) == year }
    }

    private static func stats(label: String, games: [Game], sessions: [Session]) -> SeasonStats {
        let record = StatsEngine.record(in: games)

        // Your person: most-played partner.
        var partnerCounts: [UUID: (name: String, wins: Int, losses: Int)] = [:]
        for game in games {
            guard let p = game.myPartner, p.isAlive else { continue }
            var entry = partnerCounts[p.remoteID] ?? (p.name, 0, 0)
            if game.didWin { entry.wins += 1 } else { entry.losses += 1 }
            partnerCounts[p.remoteID] = entry
        }
        let topPartner = partnerCounts.max { ($0.value.wins + $0.value.losses) < ($1.value.wins + $1.value.losses) }?.value

        let nemesis = StatsEngine.nemesis(in: games, minGames: 2)

        // Your court: most sessions.
        var courtCounts: [UUID: (name: String, count: Int)] = [:]
        for session in sessions {
            guard let c = session.court, c.isAlive else { continue }
            courtCounts[c.remoteID, default: (c.name, 0)].count += 1
        }
        let topCourt = courtCounts.max { $0.value.count < $1.value.count }?.value

        let totalMinutes = sessions.compactMap(\.activeMinutes).reduce(0, +)
        let totalCalories = sessions.compactMap(\.activeCalories).reduce(0, +)

        var people = Set<UUID>()
        for game in games {
            if let p = game.myPartner, p.isAlive { people.insert(p.remoteID) }
            for o in game.opponents ?? [] where o.isAlive { people.insert(o.remoteID) }
        }

        return SeasonStats(
            periodLabel: label,
            gamesPlayed: games.count,
            sessionsPlayed: sessions.count,
            wins: record.wins,
            losses: record.losses,
            topPartnerName: topPartner?.name,
            topPartnerRecord: topPartner.map { ($0.wins, $0.losses) },
            nemesisName: nemesis?.player.name,
            nemesisRecord: nemesis.map { ($0.wins, $0.losses) },
            topCourtName: topCourt?.name,
            topCourtSessions: topCourt?.count ?? 0,
            longestStreak: StatsEngine.longestWinStreak(in: games),
            totalMinutes: Int(totalMinutes.rounded()),
            totalCalories: Int(totalCalories.rounded()),
            pointsScored: StatsEngine.pointsForAgainst(in: games).scored,
            peopleCount: people.count
        )
    }
}
