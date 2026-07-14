import SwiftUI

/// The full timeline of your moments, most recent first.
struct MilestonesView: View {
    let milestones: [Milestone]
    @State private var sharing: Milestone?

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.rowGap) {
                ForEach(milestones) { milestone in
                    Button {
                        sharing = milestone
                    } label: {
                        MilestoneRow(milestone: milestone, showsShareHint: true)
                    }
                    .buttonStyle(DDCardButtonStyle())
                }
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.top, DD.Spacing.rowGap)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle("Moments")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sharing) { milestone in
            MilestoneShareSheet(milestone: milestone)
        }
    }
}

struct MilestoneRow: View {
    let milestone: Milestone
    var showsShareHint = false

    private var tint: Color { milestone.tint.color }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: milestone.symbol)
                .font(Font.system(size: 19, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 46, height: 46)
                .background(tint.opacity(0.16), in: Circle())
                .overlay(Circle().strokeBorder(tint.opacity(0.30), lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.headline)
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .lineLimit(1)
                Text(milestone.detail ?? milestone.caption)
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: DD.Spacing.rowGap)
            if showsShareHint {
                Image(systemName: "square.and.arrow.up")
                    .font(Font.system(size: 15, weight: .semibold))
                    .foregroundStyle(DD.Colors.accentWin)
            } else {
                Text(milestone.achievedAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(DD.Fonts.caption)
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }
}
