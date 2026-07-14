import Foundation

/// Versioned Codable payloads exchanged between watch and phone over
/// WatchConnectivity. Each is sent as ["type": "<name>.vN", "data": <JSON>].
/// The watch is the capture device; every payload carries a `remoteID`-style
/// UUID so the phone can upsert idempotently (a redelivered transfer is a
/// no-op, and out-of-order arrival still resolves once all parts land).

enum SyncType {
    static let sessionStart = "session.start.v1"
    static let game = "game.v1"
    static let sessionEnd = "session.end.v1"
    static let roster = "roster.v1"
}

struct SessionStartPayload: Codable {
    var sessionID: UUID
    var startedAt: Date
}

struct GamePayload: Codable {
    var gameID: UUID
    var sessionID: UUID
    var playedAt: Date
    var orderIndex: Int
    var myScore: Int
    var theirScore: Int
    var scoringType: String
    var targetPoints: Int
    var winBy: Int
    var partnerID: UUID?
    var partnerName: String?
}

struct SessionEndPayload: Codable {
    var sessionID: UUID
    var endedAt: Date
    var workoutUUID: UUID?
}

/// One person in the roster the phone pushes down to the watch's partner grid.
struct RosterEntry: Codable {
    var id: UUID
    var name: String
}

struct RosterPayload: Codable {
    var players: [RosterEntry]
}
