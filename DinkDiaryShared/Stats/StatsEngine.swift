import Foundation

/// Stateless derived-stat functions over value inputs. Callers fetch the games
/// (via @Query or FetchDescriptor) and pass arrays; nothing here is stored.
/// The free/premium gate simply truncates which of these render.
enum StatsEngine {

    /// Wins and losses across the given games.
    static func record(in games: [Game]) -> (wins: Int, losses: Int) {
        var wins = 0, losses = 0
        for game in games {
            if game.didWin { wins += 1 } else { losses += 1 }
        }
        return (wins, losses)
    }

    /// Your record in games where this player was your partner.
    static func record(withPartner player: Player, in games: [Game]) -> (wins: Int, losses: Int) {
        record(in: games.filter { $0.myPartner?.remoteID == player.remoteID })
    }

    /// Your record in games where this player was an opponent.
    static func record(against player: Player, in games: [Game]) -> (wins: Int, losses: Int) {
        record(in: games.filter { ($0.opponents ?? []).contains { $0.remoteID == player.remoteID } })
    }

    /// Current win streak. Caller passes games newest-first; counts leading wins.
    static func currentWinStreak(in gamesNewestFirst: [Game]) -> Int {
        var streak = 0
        for game in gamesNewestFirst {
            if game.didWin { streak += 1 } else { break }
        }
        return streak
    }

    /// How many games you played with this player as partner.
    static func gamesCount(withPartner player: Player, in games: [Game]) -> Int {
        games.filter { $0.myPartner?.remoteID == player.remoteID }.count
    }

    /// The last time you shared a court with this player (partner or opponent).
    static func lastPlayed(with player: Player, in games: [Game]) -> Date? {
        games
            .filter { game in
                game.myPartner?.remoteID == player.remoteID
                    || (game.opponents ?? []).contains { $0.remoteID == player.remoteID }
            }
            .map(\.playedAt)
            .max()
    }

    /// Games played at a court, across all its sessions.
    static func games(atCourt court: Court) -> [Game] {
        (court.sessions ?? []).flatMap { $0.games ?? [] }
    }

    // MARK: Insights

    struct PlayerRecord: Identifiable {
        let player: Player
        let wins: Int
        let losses: Int
        var id: UUID { player.remoteID }
        var total: Int { wins + losses }
        var winRate: Double { total == 0 ? 0 : Double(wins) / Double(total) }
    }

    enum TimeOfDay: String, CaseIterable, Identifiable {
        case morning, afternoon, evening
        var id: String { rawValue }
        var label: String {
            switch self {
            case .morning: return "Morning"
            case .afternoon: return "Afternoon"
            case .evening: return "Evening"
            }
        }
    }

    struct TimeBucket: Identifiable {
        let time: TimeOfDay
        let wins: Int
        let losses: Int
        var id: String { time.id }
        var total: Int { wins + losses }
        var winRate: Double { total == 0 ? 0 : Double(wins) / Double(total) }
    }

    /// Partners ranked by win rate together (min games), best chemistry first.
    static func chemistryRanking(in games: [Game], minGames: Int = 2) -> [PlayerRecord] {
        uniquePartners(in: games)
            .compactMap { player in
                let r = record(withPartner: player, in: games)
                let record = PlayerRecord(player: player, wins: r.wins, losses: r.losses)
                return record.total >= minGames ? record : nil
            }
            .sorted { $0.winRate != $1.winRate ? $0.winRate > $1.winRate : $0.total > $1.total }
    }

    /// The opponent you fare worst against (min games): a rivalry, not a failure.
    static func nemesis(in games: [Game], minGames: Int = 3) -> PlayerRecord? {
        uniqueOpponents(in: games)
            .compactMap { player -> PlayerRecord? in
                let r = record(against: player, in: games)
                let record = PlayerRecord(player: player, wins: r.wins, losses: r.losses)
                return record.total >= minGames ? record : nil
            }
            .min { a, b in a.winRate != b.winRate ? a.winRate < b.winRate : a.losses > b.losses }
    }

    /// Your record split by time of day, buckets you've actually played.
    static func timeBuckets(in games: [Game]) -> [TimeBucket] {
        var tally: [TimeOfDay: (wins: Int, losses: Int)] = [:]
        let calendar = Calendar.current
        for game in games {
            let hour = calendar.component(.hour, from: game.playedAt)
            let time: TimeOfDay = hour < 12 ? .morning : (hour < 17 ? .afternoon : .evening)
            var rec = tally[time] ?? (0, 0)
            if game.didWin { rec.wins += 1 } else { rec.losses += 1 }
            tally[time] = rec
        }
        return TimeOfDay.allCases.compactMap { time in
            guard let rec = tally[time], rec.wins + rec.losses > 0 else { return nil }
            return TimeBucket(time: time, wins: rec.wins, losses: rec.losses)
        }
    }

    /// Longest run of consecutive wins across all games in time order.
    static func longestWinStreak(in games: [Game]) -> Int {
        var best = 0, current = 0
        for game in games.sorted(by: { $0.playedAt < $1.playedAt }) {
            if game.didWin { current += 1; best = max(best, current) } else { current = 0 }
        }
        return best
    }

    /// Total points scored and allowed across the given games.
    static func pointsForAgainst(in games: [Game]) -> (scored: Int, allowed: Int) {
        games.reduce(into: (scored: 0, allowed: 0)) { totals, game in
            totals.scored += game.myScore
            totals.allowed += game.theirScore
        }
    }

    private static func uniquePartners(in games: [Game]) -> [Player] {
        var seen = Set<UUID>()
        var result: [Player] = []
        for game in games {
            guard let p = game.myPartner, p.isAlive, !seen.contains(p.remoteID) else { continue }
            seen.insert(p.remoteID)
            result.append(p)
        }
        return result
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
