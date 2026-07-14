import SwiftUI

/// The 10-second moment: a grid of recent-player faces, one tap logs the game.
/// A Solo option covers singles or "didn't note it."
struct PartnerPickerView: View {
    let roster: [RosterPlayer]
    var onPick: (RosterPlayer?) -> Void

    private let columns = [GridItem(.adaptive(minimum: 52), spacing: DD.Spacing.rowGap)]

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Partner?")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)

                LazyVGrid(columns: columns, spacing: DD.Spacing.rowGap) {
                    ForEach(roster.prefix(6)) { player in
                        Button {
                            onPick(player)
                        } label: {
                            face(player)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    onPick(nil)
                } label: {
                    Text("Solo")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .secondary))
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
    }

    private func face(_ player: RosterPlayer) -> some View {
        let tint = DD.Colors.avatarTint(seed: player.tintSeed)
        return VStack(spacing: 2) {
            Text(player.initials)
                .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(tint.opacity(0.20), in: Circle())
            Text(player.name.split(separator: " ").first.map(String.init) ?? player.name)
                .font(DD.Fonts.caption)
                .foregroundStyle(DD.Colors.textSecondary)
                .lineLimit(1)
        }
    }
}
