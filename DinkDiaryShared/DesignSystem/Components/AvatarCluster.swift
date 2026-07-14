import SwiftUI

/// A single partner avatar: initials on a tinted circle. Tint is an accent at
/// 16-25% alpha with the accent as glyph color; coral tint is reserved for
/// the nemesis.
struct AvatarView: View {
    let initials: String
    var tint: Color = DD.Colors.courtBlue
    var size: CGFloat = 40
    /// Ring color separates overlapping avatars; parent passes its background.
    var ringColor: Color = DD.Colors.surface

    var body: some View {
        Text(initials)
            .font(Font.system(size: size * 0.36, weight: .semibold, design: .rounded))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.20), in: Circle())
            .overlay(Circle().strokeBorder(ringColor, lineWidth: 2))
    }
}

/// Overlapping avatar cluster: 40pt circles, 2px surface ring, -10 overlap,
/// max 3 visible plus a "+N" chip. Empty state: dashed circle, "Add your people."
struct AvatarCluster: View {
    struct Member {
        let initials: String
        var tint: Color = DD.Colors.courtBlue
    }

    let members: [Member]
    var size: CGFloat = 40
    var maxVisible: Int = 3
    var ringColor: Color = DD.Colors.surface

    var body: some View {
        if members.isEmpty {
            emptyState
        } else {
            HStack(spacing: -10) {
                ForEach(Array(members.prefix(maxVisible).enumerated()), id: \.offset) { _, member in
                    AvatarView(initials: member.initials, tint: member.tint, size: size, ringColor: ringColor)
                }
                if members.count > maxVisible {
                    Text("+\(members.count - maxVisible)")
                        .font(DD.Fonts.statBadge)
                        .foregroundStyle(DD.Colors.textSecondary)
                        .frame(width: size, height: size)
                        .background(DD.Colors.surfacePressed, in: Circle())
                        .overlay(Circle().strokeBorder(ringColor, lineWidth: 2))
                }
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: DD.Spacing.rowGap) {
            Circle()
                .strokeBorder(
                    DD.Colors.textSecondary.opacity(0.30),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
                .frame(width: size, height: size)
            Text("Add your people.")
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }
}
