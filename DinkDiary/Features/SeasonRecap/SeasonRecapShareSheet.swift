import SwiftUI
import UIKit

/// The season summarized on one shareable card, and a sheet to send it.
struct SeasonRecapCard: View {
    let stats: SeasonStats
    let size: CGSize
    var theme: ShareTheme = .midnight

    private var w: CGFloat { size.width }

    var body: some View {
        VStack(alignment: .leading, spacing: w * 0.03) {
            Text("Your season \u{00B7} \(stats.periodLabel)")
                .font(.system(size: w * 0.03, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.003)
                .foregroundStyle(DD.Colors.textSecondary)

            Rectangle()
                .fill(DD.Colors.motifLine)
                .frame(height: w * 0.005)
                .overlay(alignment: .center) {
                    Rectangle().fill(DD.Colors.motifLine).frame(width: w * 0.005, height: w * 0.03)
                }

            Spacer(minLength: 0)

            Text("\(stats.wins)-\(stats.losses)")
                .font(.system(size: w * 0.26, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(stats.wins >= stats.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("\(stats.gamesPlayed) games \u{00B7} \(stats.sessionsPlayed) sessions")
                .font(.system(size: w * 0.035))
                .foregroundStyle(DD.Colors.textSecondary)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: w * 0.02) {
                if let name = stats.topPartnerName {
                    line("Your person", firstName(name), DD.Colors.accentWin)
                }
                if stats.longestStreak >= 2 {
                    line("Best run", "\(stats.longestStreak) in a row", DD.Colors.streak)
                }
                if let court = stats.topCourtName {
                    line("Home court", court, DD.Colors.textPrimary)
                }
                if stats.peopleCount > 0 {
                    line("Your world", "\(stats.peopleCount) people", DD.Colors.courtBlue)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: w * 0.02) {
                Circle().fill(DD.Colors.accentWin).frame(width: w * 0.02, height: w * 0.02)
                Text("Dink Diary")
                    .font(.system(size: w * 0.03, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(w * 0.075)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(theme.gradient)
    }

    private func line(_ label: String, _ value: String, _ tint: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: w * 0.032, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.002)
                .foregroundStyle(DD.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: w * 0.045, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
        }
    }

    private func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}

struct SeasonRecapShareSheet: View {
    let stats: SeasonStats
    @Environment(\.dismiss) private var dismiss

    private let exportSize = CGSize(width: 1080, height: 1920)
    @State private var theme: ShareTheme = .midnight

    var body: some View {
        NavigationStack {
            VStack(spacing: DD.Spacing.cardGap) {
                SharePickerBar(theme: $theme)
                GeometryReader { geo in
                    let scale = min(geo.size.width / exportSize.width, geo.size.height / exportSize.height)
                    SeasonRecapCard(stats: stats, size: exportSize, theme: theme)
                        .frame(width: exportSize.width, height: exportSize.height)
                        .scaleEffect(scale)
                        .frame(width: exportSize.width * scale, height: exportSize.height * scale)
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
        let renderer = ImageRenderer(content: SeasonRecapCard(stats: stats, size: exportSize, theme: theme))
        renderer.scale = 1
        guard let image = renderer.uiImage else { return nil }
        return ShareableImage(image: image, filename: "dink-diary-season")
    }
}
