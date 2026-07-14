#if DEBUG
import SwiftUI

/// DEBUG-only token and component gallery: the standing visual diff surface
/// against the locked Claude Design system. Every token and every component
/// state renders here so drift is caught by eye on every build.
struct GalleryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.gutter) {
                    colorSection
                    typeSection
                    componentSection
                    mockCardSection
                }
                .padding(DD.Spacing.gutter)
                .padding(.bottom, 100)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Gallery")
        }
    }

    // MARK: Colors

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text("Color tokens").ddCaption()
            let tokens: [(String, Color)] = [
                ("surface", DD.Colors.surface),
                ("surfaceElevated", DD.Colors.surfaceElevated),
                ("surfacePressed", DD.Colors.surfacePressed),
                ("textPrimary", DD.Colors.textPrimary),
                ("textSecondary", DD.Colors.textSecondary),
                ("accentWin", DD.Colors.accentWin),
                ("accentWinPressed", DD.Colors.accentWinPressed),
                ("accentLoss", DD.Colors.accentLoss),
                ("streak", DD.Colors.streak),
                ("courtBlue", DD.Colors.courtBlue),
                ("kitchenGreen", DD.Colors.kitchenGreen),
                ("hairline", DD.Colors.hairline),
                ("motifLine", DD.Colors.motifLine),
                ("motifDimmed", DD.Colors.motifDimmed),
            ]
            ForEach(tokens, id: \.0) { name, color in
                HStack(spacing: DD.Spacing.cardGap) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color)
                        .frame(width: 44, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(DD.Colors.hairline, lineWidth: 1)
                        )
                    Text(name)
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textPrimary)
                }
            }
        }
    }

    // MARK: Type

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text("Type scale").ddCaption()
            Text("96").font(DD.Fonts.scoreboard).foregroundStyle(DD.Colors.accentWin)
            Text("5-2").font(DD.Fonts.statLarge).foregroundStyle(DD.Colors.textPrimary)
            Text("44").font(DD.Fonts.statMedium).foregroundStyle(DD.Colors.textPrimary)
            Text("28").font(DD.Fonts.statSmall).foregroundStyle(DD.Colors.textPrimary)
            Text("Your season").font(DD.Fonts.largeTitle).foregroundStyle(DD.Colors.textPrimary)
            Text("Sarah").font(DD.Fonts.title1).foregroundStyle(DD.Colors.textPrimary)
            Text("Sunset Park").font(DD.Fonts.title3).foregroundStyle(DD.Colors.textPrimary)
            Text("Start a session").font(DD.Fonts.headline).foregroundStyle(DD.Colors.textPrimary)
            Text("Body copy sounds like your favorite doubles partner.")
                .font(DD.Fonts.body).foregroundStyle(DD.Colors.textPrimary)
            Text("Footnote metadata").font(DD.Fonts.footnote).foregroundStyle(DD.Colors.textSecondary)
            Text("Caption label").ddCaption()
        }
    }

    // MARK: Components

    private var componentSection: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            Text("Components").ddCaption()

            PillButton(title: "Start a session") {}
            PillButton(title: "Secondary", variant: .secondary) {}
            PillButton(title: "Disabled") {}.disabled(true)

            HStack(spacing: DD.Spacing.rowGap) {
                WinLossPill(didWin: true, score: "11-7")
                WinLossPill(didWin: false, score: "9-11")
                StreakBadge(count: 7)
                StreakBadge.empty
            }

            HStack(spacing: DD.Spacing.rowGap) {
                StatTile(label: "Active", value: "41m", tint: DD.Colors.kitchenGreen)
                StatTile(label: "Cal", value: "780", tint: DD.Colors.kitchenGreen)
                StatTile(label: "Win rate", value: "71%", tint: DD.Colors.accentWin)
            }
            HStack(spacing: DD.Spacing.rowGap) {
                StatTile(label: "Peak HR")
                StatTile(label: "Games", value: "7")
            }

            AvatarCluster(members: [
                .init(initials: "SM", tint: DD.Colors.courtBlue),
                .init(initials: "MK", tint: DD.Colors.kitchenGreen),
                .init(initials: "DL", tint: DD.Colors.accentLoss),
                .init(initials: "JR", tint: DD.Colors.streak),
            ])
            AvatarCluster(members: [])

            VStack(spacing: DD.Spacing.rowGap) {
                KitchenLineMotif()
                KitchenLineMotif(dimmed: true)
            }
        }
    }

    // MARK: Mock session card

    private var mockCardSection: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text("Session card, composed").ddCaption()

            VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                HStack {
                    Text("Tue, Jul 14 · Sunset Park").ddCaption()
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "sun.max.fill")
                            .font(Font.system(size: 11, weight: .medium))
                        Text("78°").font(DD.Fonts.caption)
                    }
                    .foregroundStyle(DD.Colors.courtBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DD.Colors.courtBlue.opacity(0.14), in: Capsule())
                }

                KitchenLineMotif()

                HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
                    Text("5-2")
                        .font(Font.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(DD.Colors.accentWin)
                    Text("7 games")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }

                HStack {
                    AvatarCluster(members: [
                        .init(initials: "SM", tint: DD.Colors.courtBlue),
                        .init(initials: "MK", tint: DD.Colors.kitchenGreen),
                        .init(initials: "DL", tint: DD.Colors.streak),
                    ], size: 32, ringColor: DD.Colors.surfaceElevated)
                    Spacer()
                    Text("41 min · 780 cal")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.kitchenGreen)
                }
            }
            .padding(DD.Spacing.cardPadding)
            .background(
                DD.Colors.surfaceElevated,
                in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous)
            )
        }
    }
}
#endif
