import SwiftUI
import UIKit

/// A shareable card about you and one person: your record as partners and as
/// rivals, with a warm tagline. A losing head to head reads as a rivalry, never
/// a failure. Metrics scale with `size.width` so it renders crisp at preview and
/// export sizes alike.
struct HeadToHeadCardView: View {
    let player: Player
    let allGames: [Game]
    let size: CGSize
    var theme: ShareTheme = .midnight

    private var w: CGFloat { size.width }
    private var first: String { player.name.split(separator: " ").first.map(String.init) ?? player.name }

    private var together: (wins: Int, losses: Int) { StatsEngine.record(withPartner: player, in: allGames) }
    private var against: (wins: Int, losses: Int) { StatsEngine.record(against: player, in: allGames) }
    private var partnerTotal: Int { together.wins + together.losses }
    private var rivalTotal: Int { against.wins + against.losses }
    private var partnerDominant: Bool { partnerTotal >= rivalTotal }

    /// The hero record and its framing depend on the primary relationship.
    private var hero: (value: String, tint: Color, caption: String) {
        if partnerDominant {
            let winning = together.wins >= together.losses
            return ("\(together.wins)-\(together.losses)",
                    winning ? DD.Colors.accentWin : DD.Colors.textPrimary,
                    "as a team")
        } else {
            let winning = against.wins >= against.losses
            return ("\(against.wins)-\(against.losses)",
                    winning ? DD.Colors.accentWin : DD.Colors.textPrimary,
                    "when it's you against them")
        }
    }

    private var tagline: String {
        if partnerDominant {
            if together.wins > together.losses { return "Chemistry, certified." }
            if together.wins == together.losses { return "Even, and always a good time." }
            return "Still writing this one together."
        } else {
            let theirWins = against.losses, myWins = against.wins
            if myWins > theirWins { return "Right now, you own it." }
            if myWins == theirWins { return "Dead even. The dangerous kind." }
            return "A rivalry, not a verdict. One day."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: w * 0.03) {
            Text(partnerDominant ? "You + \(first)" : "You vs \(first)")
                .font(.system(size: w * 0.03, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.003)
                .foregroundStyle(DD.Colors.textSecondary)

            avatar

            Spacer(minLength: 0)

            Text(hero.value)
                .font(.system(size: w * 0.26, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(hero.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(hero.caption)
                .font(.system(size: w * 0.035))
                .foregroundStyle(DD.Colors.textSecondary)

            Spacer(minLength: 0)

            HStack(spacing: w * 0.03) {
                statBlock(value: "\(together.wins)-\(together.losses)", label: "Together")
                statBlock(value: "\(against.wins)-\(against.losses)", label: "Against")
            }

            Text(tagline)
                .font(.system(size: w * 0.04, weight: .semibold))
                .foregroundStyle(DD.Colors.textPrimary)
                .padding(.top, w * 0.01)

            Spacer(minLength: 0)

            mark
        }
        .padding(w * 0.075)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(theme.gradient)
    }

    private var avatar: some View {
        let tint = DD.Colors.avatarTint(seed: player.tintSeed)
        return Text(player.initials)
            .font(.system(size: w * 0.05, weight: .semibold, design: .rounded))
            .foregroundStyle(tint)
            .frame(width: w * 0.14, height: w * 0.14)
            .background(tint.opacity(0.20), in: Circle())
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: w * 0.005) {
            Text(value)
                .font(.system(size: w * 0.07, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(DD.Colors.textPrimary)
            Text(label)
                .font(.system(size: w * 0.028, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.002)
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, w * 0.025)
        .padding(.horizontal, w * 0.03)
        .background(DD.Colors.surface.opacity(0.55), in: .rect(cornerRadius: w * 0.03, style: .continuous))
    }

    private var mark: some View {
        HStack(spacing: w * 0.02) {
            Circle().fill(DD.Colors.accentWin).frame(width: w * 0.02, height: w * 0.02)
            Text("Dink Diary")
                .font(.system(size: w * 0.03, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }
}

/// Preview and send a head-to-head card, with frame and theme pickers.
struct HeadToHeadShareSheet: View {
    let player: Player
    let allGames: [Game]
    @Environment(\.dismiss) private var dismiss

    @State private var frame: ShareFrame = .story
    @State private var theme: ShareTheme = .midnight

    var body: some View {
        NavigationStack {
            VStack(spacing: DD.Spacing.cardGap) {
                ShareFramePicker(frame: $frame)
                SharePickerBar(theme: $theme)

                GeometryReader { geo in
                    let target = frame.exportSize
                    let scale = min(geo.size.width / target.width, geo.size.height / target.height)
                    HeadToHeadCardView(player: player, allGames: allGames, size: target, theme: theme)
                        .frame(width: target.width, height: target.height)
                        .scaleEffect(scale)
                        .frame(width: target.width * scale, height: target.height * scale)
                        .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                shareButton
            }
            .padding(DD.Spacing.gutter)
            .background(DD.Colors.surface)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(DD.Colors.textSecondary)
                }
            }
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let shareable = makeShareable() {
            ShareLink(item: shareable, preview: SharePreview("Dink Diary", image: Image(uiImage: shareable.image))) {
                Text("Share")
                    .font(DD.Fonts.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(DDPillButtonStyle(variant: .primary))
        }
    }

    @MainActor
    private func makeShareable() -> ShareableImage? {
        let card = HeadToHeadCardView(player: player, allGames: allGames, size: frame.exportSize, theme: theme)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 1
        guard let image = renderer.uiImage else { return nil }
        return ShareableImage(image: image, filename: "dink-diary-head-to-head")
    }
}
