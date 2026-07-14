import SwiftUI
import UIKit

/// A single celebrated moment, rendered for sharing. A big glyph on a tinted
/// halo, the moment's headline, a warm/funny caption, an optional detail, and
/// the date it happened. The tint color washes the whole card subtly so each
/// kind of moment feels distinct.
struct MilestoneCardView: View {
    let milestone: Milestone
    let size: CGSize
    var theme: ShareTheme = .midnight

    private var w: CGFloat { size.width }
    private var tint: Color { milestone.tint.color }

    var body: some View {
        VStack(alignment: .leading, spacing: w * 0.035) {
            Text("A moment \u{00B7} \(milestone.achievedAt.formatted(.dateTime.month(.wide).day().year()))")
                .font(.system(size: w * 0.03, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.003)
                .foregroundStyle(DD.Colors.textSecondary)

            Spacer(minLength: 0)

            Image(systemName: milestone.symbol)
                .font(.system(size: w * 0.17, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: w * 0.32, height: w * 0.32)
                .background(
                    Circle()
                        .fill(tint.opacity(0.18))
                        .overlay(Circle().strokeBorder(tint.opacity(0.45), lineWidth: w * 0.006))
                )

            VStack(alignment: .leading, spacing: w * 0.015) {
                Text(milestone.headline)
                    .font(.system(size: w * 0.11, weight: .heavy, design: .rounded))
                    .foregroundStyle(DD.Colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                Text(milestone.caption)
                    .font(.system(size: w * 0.042, weight: .regular))
                    .foregroundStyle(DD.Colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let detail = milestone.detail {
                Text(detail)
                    .font(.system(size: w * 0.038, weight: .semibold, design: .rounded))
                    .foregroundStyle(tint)
                    .padding(.horizontal, w * 0.035)
                    .padding(.vertical, w * 0.02)
                    .background(tint.opacity(0.14), in: Capsule())
            }

            Spacer(minLength: 0)

            HStack(spacing: w * 0.02) {
                Circle().fill(tint).frame(width: w * 0.022, height: w * 0.022)
                Text("Dink Diary")
                    .font(.system(size: w * 0.03, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
                Spacer()
                Text(milestone.achievedAt.formatted(.dateTime.year()))
                    .font(.system(size: w * 0.03, weight: .medium))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(w * 0.075)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(
            ZStack {
                theme.gradient
                RadialGradient(
                    colors: [tint.opacity(0.22), Color.clear],
                    center: .topLeading, startRadius: 0, endRadius: w * 0.9
                )
            }
        )
    }
}

/// A quiet celebration when a new moment lands, with a one-tap path to share it.
struct MilestoneCelebrationView: View {
    let milestone: Milestone
    @Environment(\.dismiss) private var dismiss
    @State private var showingShare = false

    var body: some View {
        VStack(spacing: DD.Spacing.gutter) {
            Spacer()
            Text("New moment")
                .font(DD.Fonts.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(DD.Colors.accentWin)
            MilestoneRow(milestone: milestone)
            Text("That one is worth showing off.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: DD.Spacing.rowGap) {
                PillButton(title: "Share it") { showingShare = true }
                Button("Maybe later") { dismiss() }
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(DD.Spacing.gutter)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DD.Colors.surface)
        .sheet(isPresented: $showingShare) {
            MilestoneShareSheet(milestone: milestone)
        }
    }
}

/// Preview and send a milestone card, with frame and theme pickers.
struct MilestoneShareSheet: View {
    let milestone: Milestone
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
                    MilestoneCardView(milestone: milestone, size: target, theme: theme)
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
        let renderer = ImageRenderer(content: MilestoneCardView(milestone: milestone, size: frame.exportSize, theme: theme))
        renderer.scale = 1
        guard let image = renderer.uiImage else { return nil }
        return ShareableImage(image: image, filename: "dink-diary-moment")
    }
}
