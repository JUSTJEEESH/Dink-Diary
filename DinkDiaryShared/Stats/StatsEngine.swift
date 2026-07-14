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
}
