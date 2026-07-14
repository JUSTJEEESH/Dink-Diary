import SwiftUI

/// The scoring face, matched to the mock and filling the whole screen. Ignores
/// the safe area so nothing floats in a margin; the system draws the time over
/// the top corner. Symmetric around the net: serve pill and THEM at the top
/// edge, our number and them number hugging the net, US and mode chip at the
/// bottom edge. The serving team carries an optic dot by its label. Tap a side
/// and it scores, one tap, immediately. Color is the identity: the bright optic
/// number is always you (bottom). Long-press anywhere to undo.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas

            VStack(spacing: 0) {
                Button {
                    tap(.them)
                } label: {
                    VStack(spacing: 3) {
                        servePill
                        teamLabel(.them)
                        Spacer(minLength: 0)
                        numeral(engine.themScore, color: DD.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 2)
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
                    VStack(spacing: 3) {
                        numeral(engine.usScore, color: DD.Colors.accentWin)
                        Spacer(minLength: 0)
                        teamLabel(.us)
                        modeChip
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .ignoresSafeArea()
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    /// 80pt scoreboard numeral, with the font's line-height whitespace pulled
    /// back (negative vertical padding) so the visible digit fills more of the
    /// space. minimumScaleFactor keeps two-digit scores fitting on any watch.
    private func numeral(_ value: Int, color: Color) -> some View {
        Text("\(value)")
            .font(DD.Fonts.watchScore)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.vertical, -12)
    }

    private func teamLabel(_ team: Team) -> some View {
        HStack(spacing: 4) {
            if engine.servingTeam == team {
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 6, height: 6)
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
            .padding(.vertical, 3)
            .background(DD.Colors.accentWin, in: Capsule())
    }

    private var modeChip: some View {
        Text(engine.mode == .sideOut ? "SIDE OUT" : "RALLY")
            .font(DD.Fonts.caption)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.textSecondary)
            .padding(.horizontal, 12)
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
