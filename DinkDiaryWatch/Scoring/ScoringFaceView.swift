import SwiftUI

/// The scoring face, matched to the locked mock: THEM on top, US on bottom, a
/// net divider between them, a solid optic serve pill pinned top, a solid mode
/// chip pinned bottom. You tap the side that WON the rally; the engine applies
/// side-out or rally rules. The serving team carries an optic dot by its label.
/// Long-press anywhere to undo. Canvas is true black.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                half(team: .them, score: engine.themScore, color: DD.Colors.textPrimary, labelOnTop: true)

                // Net line (the mock's divider). The kitchen-line motif reads as
                // the net here; see note to the design owner.
                KitchenLineMotif()
                    .padding(.horizontal, DD.Spacing.rowGap)
                    .allowsHitTesting(false)

                half(team: .us, score: engine.usScore, color: DD.Colors.accentWin, labelOnTop: false)
            }

            VStack {
                servePill
                Spacer()
                modeChip
            }
            .padding(.vertical, 4)
            .allowsHitTesting(false)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    private func half(team: Team, score: Int, color: Color, labelOnTop: Bool) -> some View {
        Button {
            tap(team)
        } label: {
            VStack(spacing: 2) {
                if labelOnTop { teamLabel(team) }
                Text("\(score)")
                    .font(DD.Fonts.watchScore)
                    .foregroundStyle(color)
                if !labelOnTop { teamLabel(team) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func teamLabel(_ team: Team) -> some View {
        HStack(spacing: 4) {
            if engine.servingTeam == team {
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 5, height: 5)
            }
            Text(team == .us ? "US" : "THEM").ddCaption()
        }
    }

    private var servePill: some View {
        Text(serveLabel)
            .font(DD.Fonts.caption)
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.surface)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(DD.Colors.accentWin, in: Capsule())
    }

    private var modeChip: some View {
        Text(engine.mode == .sideOut ? "SIDE OUT" : "RALLY")
            .font(DD.Fonts.caption)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(DD.Colors.surfaceElevated, in: Capsule())
    }

    private var serveLabel: String {
        engine.mode == .sideOut ? "SRV \(engine.serverNumber)" : "SRV"
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
