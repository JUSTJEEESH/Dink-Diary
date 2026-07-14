import Foundation
import Observation

/// The watch's own session state. No SwiftData on the wrist: the phone is the
/// source of truth. This keeps the in-progress session in memory and persists
/// it to a JSON file after every change so a crash or wrist-drop mid-session
/// never loses logged games. M3 adds the flush-to-phone step in `endSession`.
@Observable
final class WatchSessionStore {
    private(set) var isActive = false
    private(set) var sessionID: UUID?
    private(set) var startedAt: Date?
    private(set) var games: [WatchGame] = []
    var roster: [RosterPlayer] = []

    init() {
        loadPlaceholderRoster()
        restore()
    }

    var record: (wins: Int, losses: Int) {
        var wins = 0, losses = 0
        for game in games {
            if game.didWin { wins += 1 } else { losses += 1 }
        }
        return (wins, losses)
    }

    var gameCount: Int { games.count }
    var hasUnfinishedSession: Bool { isActive && !games.isEmpty }

    func startSession() {
        isActive = true
        sessionID = UUID()
        startedAt = .now
        games = []
        persist()
    }

    func addGame(_ game: WatchGame) {
        games.append(game)
        persist()
    }

    func endSession() {
        isActive = false
        sessionID = nil
        games = []
        startedAt = nil
        persist()
    }

    /// Replace the partner grid with the roster the phone pushed down.
    func updateRoster(_ players: [RosterPlayer]) {
        roster = players
    }

    // MARK: Persistence

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("current-session.json")
    }

    private struct Snapshot: Codable {
        var isActive: Bool
        var sessionID: UUID?
        var startedAt: Date?
        var games: [WatchGame]
    }

    private func persist() {
        let snapshot = Snapshot(isActive: isActive, sessionID: sessionID, startedAt: startedAt, games: games)
        if let data = try? JSONEncoder().encode(snapshot) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    private func restore() {
        guard let data = try? Data(contentsOf: fileURL),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        isActive = snapshot.isActive
        sessionID = snapshot.sessionID
        startedAt = snapshot.startedAt
        games = snapshot.games
    }

    /// Placeholder until M3 pushes the real roster from the phone.
    private func loadPlaceholderRoster() {
        roster = [
            "Sarah Miller", "Mike Kim", "Dave Lopez",
            "Jen Ruiz", "Tom Vela", "Amy Cho",
        ].map { RosterPlayer(id: UUID(), name: $0) }
    }
}
