import Foundation
import WatchConnectivity

/// Watch side of the phone link. Sends each session start, game, and session end
/// via transferUserInfo (queued, survives being offline or relaunched) and
/// receives the roster the phone pushes as application context.
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    weak var store: WatchSessionStore?

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendSessionStart(sessionID: UUID, startedAt: Date) {
        send(type: SyncType.sessionStart,
             payload: SessionStartPayload(sessionID: sessionID, startedAt: startedAt))
    }

    func sendGame(_ payload: GamePayload) {
        send(type: SyncType.game, payload: payload)
    }

    func sendSessionEnd(sessionID: UUID, endedAt: Date, workoutUUID: UUID?) {
        send(type: SyncType.sessionEnd,
             payload: SessionEndPayload(sessionID: sessionID, endedAt: endedAt, workoutUUID: workoutUUID))
    }

    private func send<T: Encodable>(type: String, payload: T) {
        guard WCSession.isSupported(),
              let data = try? JSONEncoder().encode(payload) else { return }
        WCSession.default.transferUserInfo(["type": type, "data": data])
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Adopt any roster already delivered before this launch.
        applyRoster(from: session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        applyRoster(from: applicationContext)
    }

    private func applyRoster(from context: [String: Any]) {
        guard let data = context["roster"] as? Data,
              let payload = try? JSONDecoder().decode(RosterPayload.self, from: data) else { return }
        let players = payload.players.map { RosterPlayer(id: $0.id, name: $0.name) }
        guard !players.isEmpty else { return }
        Task { @MainActor in
            store?.updateRoster(players)
        }
    }
}
