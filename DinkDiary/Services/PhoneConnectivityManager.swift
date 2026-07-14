import Foundation
import SwiftData
import WatchConnectivity

/// Phone side of the watch link. Receives session/game payloads (delivered even
/// after relaunch, since the watch sends via transferUserInfo) and ingests them;
/// pushes the current roster down to the watch as the latest application context.
final class PhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()

    private var container: ModelContainer?

    func start(container: ModelContainer) {
        self.container = container
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Push up to eight most-recent people to the watch's partner grid.
    func sendCurrentRoster() {
        guard let container,
              WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }

        Task { @MainActor in
            let descriptor = FetchDescriptor<Player>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            let players = (try? container.mainContext.fetch(descriptor)) ?? []
            let entries = players.prefix(8).map { RosterEntry(id: $0.remoteID, name: $0.name) }
            guard let data = try? JSONEncoder().encode(RosterPayload(players: Array(entries))) else { return }
            try? WCSession.default.updateApplicationContext(["roster": data])
        }
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let type = userInfo["type"] as? String,
              let data = userInfo["data"] as? Data,
              let container else { return }

        Task { @MainActor in
            let context = container.mainContext
            switch type {
            case SyncType.sessionStart:
                if let payload = try? JSONDecoder().decode(SessionStartPayload.self, from: data) {
                    SessionIngestor.ingest(start: payload, into: context)
                }
            case SyncType.game:
                if let payload = try? JSONDecoder().decode(GamePayload.self, from: data) {
                    SessionIngestor.ingest(game: payload, into: context)
                }
            case SyncType.sessionEnd:
                if let payload = try? JSONDecoder().decode(SessionEndPayload.self, from: data) {
                    SessionIngestor.ingest(end: payload, into: context)
                    await HealthEnricher.enrichPending(container: container)
                }
            default:
                break
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            sendCurrentRoster()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
