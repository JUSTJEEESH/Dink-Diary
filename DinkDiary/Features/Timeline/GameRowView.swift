import SwiftUI

/// Game row per components.md: surfaceElevated r16, 32pt tinted avatar,
/// "w/ First" headline + "vs X & Y" footnote, W/L pill right.
struct GameRowView: View {
    let game: Game

    private var partner: Player? {
        guard let p = game.myPartner, p.isAlive else { return nil }
        return p
    }
    private var partnerName: String { partner?.name ?? "Solo" }
    private var partnerInitials: String { partner?.initials ?? "?" }
    private var partnerTint: Color {
        partner.map { DD.Colors.avatarTint(seed: $0.tintSeed) } ?? DD.Colors.textSecondary
    }
    private var opponentsText: String {
        let names = (game.opponents ?? []).filter { $0.isAlive }.map(\.name).filter { !$0.isEmpty }
        return names.isEmpty ? "" : "vs " + names.joined(separator: " & ")
    }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            AvatarView(
                initials: partnerInitials,
                tint: partnerTint,
                size: 32,
                ringColor: DD.Colors.surfaceElevated
            )
            VStack(alignment: .leading, spacing: 2) {
                Text("w/ \(partnerName)")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
                if !opponentsText.isEmpty {
                    Text(opponentsText)
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
            Spacer(minLength: DD.Spacing.rowGap)
            WinLossPill(didWin: game.didWin, score: "\(game.myScore)-\(game.theirScore)")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
        )
    }
}
