import SwiftUI

/// The scoring face. Whole-screen halves are the tap targets: bottom = us (the
/// wearer, in optic), top = them. You tap the side that WON the rally; the
/// engine applies side-out or rally rules, so the score only moves when the
/// rules say it should. Serve state is shown so that reads naturally. Long-press
/// anywhere to undo. Canvas is true black.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                scoreHalf(team: .them, score: engine.themScore, color: DD.Colors.textPrimary)
                scoreHalf(team: .us, score: engine.usScore, color: DD.Colors.accentWin)
            }

            VStack {
                servePill
                Spacer()
                modeChip
            }
            .padding(.vertical, 2)
            .allowsHitTesting(false)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    private func scoreHalf(team: Team, score: Int, color: Color) -> some View {
        Button {
            tap(team)
        } label: {
            Text("\(score)")
                .font(DD.Fonts.watchScore)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var servePill: some View {
        Text(serveLabel)
            .font(DD.Fonts.caption)
            .foregroundStyle(engine.servingTeam == .us ? DD.Colors.accentWin : DD.Colors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                (engine.servingTeam == .us ? DD.Colors.accentWin : DD.Colors.textSecondary).opacity(0.16),
                in: Capsule()
            )
    }

    private var modeChip: some View {
        Text(engine.mode == .sideOut ? "SIDE OUT" : "RALLY")
            .font(DD.Fonts.caption)
            .foregroundStyle(DD.Colors.textSecondary)
    }

    private var serveLabel: String {
        let who = engine.servingTeam == .us ? "YOU" : "THEM"
        return engine.mode == .sideOut ? "\(who) SRV \(engine.serverNumber)" : "\(who) SRV"
    }

    private func tap(_ team: Team) {
        engine.rallyWon(by: team)
        WatchHaptics.tap()
        if engine.isGameOver {
            WatchHaptics.confirm()
            onGameOver()
        }
    }

    private func undo() {
        if engine.undo() {
            WatchHaptics.undo()
        }
    }
}
