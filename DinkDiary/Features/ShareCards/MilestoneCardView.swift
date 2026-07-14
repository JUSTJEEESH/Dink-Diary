import SwiftUI
import UIKit

/// A single celebrated moment, rendered for sharing. Big symbol, the milestone
/// title, its warm subtitle, and the date it actually happened.
struct MilestoneCardView: View {
    let milestone: Milestone
    let size: CGSize
    var theme: ShareTheme = .midnight

    private var w: CGFloat { size.width }

    private var tint: Color {
        switch milestone.kind {
        case .streak: return DD.Colors.streak
        case .partner: return DD.Colors.accentWin
        case .people: return DD.Colors.courtBlue
        case .courts: return DD.Colors.kitchenGreen
        default: return DD.Colors.textPrimary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: w * 0.03) {
            Text("A moment \u{00B7} \(milestone.achievedAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                .font(.system(size: w * 0.03, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.003)
                .foregroundStyle(DD.Colors.textSecondary)

            Spacer(minLength: 0)

            Image(systemName: milestone.symbol)
                .font(.system(size: w * 0.16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: w * 0.28, height: w * 0.28)
                .background(tint.opacity(0.16), in: Circle())

            Text(milestone.title)
                .font(.system(size: w * 0.11, weight: .heavy, design: .rounded))
                .foregroundStyle(DD.Colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            Text(milestone.subtitle)
                .font(.system(size: w * 0.04, weight: .regular))
                .foregroundStyle(DD.Colors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

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
