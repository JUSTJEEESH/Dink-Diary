import SwiftUI

/// Drives the wrist flow as a small state machine:
/// idle -> scoring -> confirm -> partner -> logged -> (next game | summary).
struct WatchRootView: View {
    let store: WatchSessionStore

    @State private var phase: Phase = .idle
    @State private var engine = ScoreEngine(mode: .sideOut)
    @State private var mode: ScoringType = .sideOut
    @State private var target: Int = 11
    @State private var lastGame: WatchGame?

    enum Phase {
        case idle, scoring, confirm, partner, logged, summary
    }

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()
            content
        }
        .onAppear {
            WatchConnectivityManager.shared.store = store
            WatchConnectivityManager.shared.activate()
            // Recover an interrupted session straight to the between-games hub.
            if store.hasUnfinishedSession { phase = .logged }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .idle:
            StartView(mode: $mode, target: $target) { startNewGame() }

        case .scoring:
            ScoringFaceView(engine: $engine) { phase = .confirm }

        case .confirm:
            GameOverConfirmView(
                didWin: engine.winner == .us,
                myScore: engine.usScore,
                theirScore: engine.themScore,
                onConfirm: { phase = .partner },
                onFix: { phase = .scoring }
            )

        case .partner:
            PartnerPickerView(roster: store.roster) { picked in
                logGame(partner: picked)
            }

        case .logged:
            LoggedView(
                lastGame: lastGame,
                gameNumber: store.gameCount,
                onNext: { startNewGame() },
                onEnd: { phase = .summary }
            )

        case .summary:
            SessionSummaryView(
                record: store.record,
                gameCount: store.gameCount,
                durationText: durationText
            ) {
                if let sessionID = store.sessionID {
                    WatchConnectivityManager.shared.sendSessionEnd(
                        sessionID: sessionID, endedAt: .now, workoutUUID: nil
                    )
                }
                store.endSession()
                phase = .idle
            }
        }
    }

    private var durationText: String? {
        guard let start = store.startedAt else { return nil }
        let seconds = Int(Date.now.timeIntervalSince(start))
        guard seconds >= 0 else { return nil }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        }
        return "\(minutes)m"
    }

    private func startNewGame() {
        if !store.isActive {
            store.startSession()
            if let sessionID = store.sessionID, let startedAt = store.startedAt {
                WatchConnectivityManager.shared.sendSessionStart(sessionID: sessionID, startedAt: startedAt)
            }
        }
        engine = ScoreEngine(mode: mode, targetPoints: target, winBy: 2)
        phase = .scoring
    }

    private func logGame(partner: RosterPlayer?) {
        let game = WatchGame(
            myScore: engine.usScore,
            theirScore: engine.themScore,
            mode: mode,
            targetPoints: target,
            winBy: 2,
            partnerID: partner?.id,
            partnerName: partner?.name
        )
        store.addGame(game)
        lastGame = game

        if let sessionID = store.sessionID {
            WatchConnectivityManager.shared.sendGame(
                GamePayload(
                    gameID: game.id,
                    sessionID: sessionID,
                    playedAt: game.playedAt,
                    orderIndex: store.gameCount - 1,
                    myScore: game.myScore,
                    theirScore: game.theirScore,
                    scoringType: game.mode.rawValue,
                    targetPoints: game.targetPoints,
                    winBy: game.winBy,
                    partnerID: game.partnerID,
                    partnerName: game.partnerName
                )
            )
        }

        phase = .logged
    }
}
