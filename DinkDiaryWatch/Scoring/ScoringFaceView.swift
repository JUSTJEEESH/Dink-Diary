import SwiftUI

/// The scoring face. A dead-simple scoreboard: tap a side and that side scores,
/// one tap, immediately. Matched to the mock: serve pill on top, THEM over its
/// number, the net line, our number over US, mode chip at the bottom. The
/// serving team carries an optic dot by its label. Color is the identity: the
/// bright optic number is always you (bottom). Long-press anywhere to undo.
/// Canvas is true black.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Button {
                    tap(.them)
                } label: {
                    VStack(spacing: 2) {
                        servePill
                        teamLabel(.them)
                        numeral(engine.themScore, color: DD.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Net line (the mock's divider). The kitchen-line motif reads as
                // the net here; see note to the design owner.
                KitchenLineMotif()
                    .padding(.horizontal, DD.Spacing.rowGap)
                    .allowsHitTesting(false)

                Button {
                    tap(.us)
                } label: {
                    VStack(spacing: 2) {
                        numeral(engine.usScore, color: DD.Colors.accentWin)
                        teamLabel(.us)
                        modeChip
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    /// Fills the leftover height in the half and scales the glyph down from an
    /// oversized base, so the number is as large as the space allows.
    private func numeral(_ value: Int, color: Color) -> some View {
        Text("\(value)")
            .font(DD.Fonts.watchScoreFill)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(DD.Colors.accentWin, in: Capsule())
    }

    private var modeChip: some View {
        Text(engine.mode == .sideOut ? "SIDE OUT" : "RALLY")
            .font(DD.Fonts.caption)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(DD.Colors.surfaceElevated, in: Capsule())
    }

    private var serveLabel: String {
        engine.mode == .sideOut ? "SRV \(engine.serverNumber)" : "SRV"
    }

    private func tap(_ team: Team) {
        engine.addPoint(to: team)
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
