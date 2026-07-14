import Foundation
import SwiftData

/// Writes watch payloads into the phone's store. Everything upserts by
/// `remoteID`, so a redelivered transfer is harmless and a game that arrives
/// before its session start just creates a stub session the start/end fill in.
enum SessionIngestor {

    @MainActor
    static func ingest(start payload: SessionStartPayload, into context: ModelContext) {
        let session = fetchOrCreateSession(payload.sessionID, in: context)
        session.startedAt = payload.startedAt
        session.sourceRaw = "watch"
        try? context.save()
    }

    @MainActor
    static func ingest(game payload: GamePayload, into context: ModelContext) {
        let session = fetchOrCreateSession(payload.sessionID, in: context)

        let gameID = payload.gameID
        let existing = try? context.fetch(
            FetchDescriptor<Game>(predicate: #Predicate { $0.remoteID == gameID })
        ).first
        let game = existing ?? Game()

        game.remoteID = payload.gameID
        game.playedAt = payload.playedAt
        game.orderIndex = payload.orderIndex
        game.myScore = payload.myScore
        game.theirScore = payload.theirScore
        game.scoringTypeRaw = payload.scoringType
        game.session = session
        if let partnerID = payload.partnerID {
            game.myPartner = fetchOrCreatePlayer(id: partnerID, name: payload.partnerName ?? "", in: context)
        }

        if existing == nil {
            context.insert(game)
        }
        try? context.save()
    }

    @MainActor
    static func ingest(end payload: SessionEndPayload, into context: ModelContext) {
        let session = fetchOrCreateSession(payload.sessionID, in: context)
        session.endedAt = payload.endedAt
        session.healthKitWorkoutID = payload.workoutUUID
        try? context.save()
    }

    @MainActor
    private static func fetchOrCreateSession(_ id: UUID, in context: ModelContext) -> Session {
        if let existing = try? context.fetch(
            FetchDescriptor<Session>(predicate: #Predicate { $0.remoteID == id })
        ).first {
            return existing
        }
        let session = Session(sourceRaw: "watch")
        session.remoteID = id
        context.insert(session)
        return session
    }

    @MainActor
    private static func fetchOrCreatePlayer(id: UUID, name: String, in context: ModelContext) -> Player {
        if let existing = try? context.fetch(
            FetchDescriptor<Player>(predicate: #Predicate { $0.remoteID == id })
        ).first {
            return existing
        }
        let player = Player(name: name)
        player.remoteID = id
        context.insert(player)
        return player
    }
}
