import SwiftUI

/// The scoring face, built for glanceability: two giant numbers, one per half,
/// each filling its space so the score reads at arm's length in full sun. Color
/// is the identity, the bright optic number is always you (bottom), the warm
/// white one is them (top). A compact serve pill sits above, a mode chip below,
/// split by the net line. Each half is one big tap target: tap the side that
/// WON the rally and the engine applies side-out or rally rules. Long-press
/// anywhere to undo. Canvas is true black.
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

    /// Fills the half and scales the glyph down from an oversized base, so the
    /// number is as large as the space allows on any watch.
    private func numeral(_ value: Int, color: Color) -> some View {
        Text("\(value)")
            .font(DD.Fonts.watchScoreFill)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
