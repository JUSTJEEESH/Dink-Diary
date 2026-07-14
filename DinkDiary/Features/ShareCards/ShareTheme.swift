import SwiftUI

/// The look of a share card. One small set of tasteful backgrounds inside the
/// locked palette family, so a shared card always feels like Dink Diary.
enum ShareTheme: String, CaseIterable, Identifiable {
    case midnight = "Midnight"
    case optic = "Optic"
    case minimal = "Minimal"

    var id: String { rawValue }

    var gradient: LinearGradient {
        switch self {
        case .midnight:
            return LinearGradient(
                colors: [DD.Colors.gradientTop, DD.Colors.surface],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .optic:
            return LinearGradient(
                colors: [DD.Colors.kitchenGreen.opacity(0.35), DD.Colors.surface],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .minimal:
            return LinearGradient(
                colors: [DD.Colors.surfaceElevated, DD.Colors.surface],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

/// Story (9:16) or square (1:1) export size.
enum ShareFrame: String, CaseIterable, Identifiable {
    case story = "Story"
    case square = "Square"

    var id: String { rawValue }

    var exportSize: CGSize {
        switch self {
        case .story: return CGSize(width: 1080, height: 1920)
        case .square: return CGSize(width: 1080, height: 1080)
        }
    }
}

/// A reusable frame picker row for the share sheets.
struct ShareFramePicker: View {
    @Binding var frame: ShareFrame

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ShareFrame.allCases) { option in
                Button {
                    frame = option
                } label: {
                    Text(option.rawValue)
                        .font(DD.Fonts.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(frame == option ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(frame == option ? DD.Colors.accentWin : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }
}

/// A reusable theme picker row for the share sheets.
struct SharePickerBar: View {
    @Binding var theme: ShareTheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ShareTheme.allCases) { option in
                Button {
                    theme = option
                } label: {
                    Text(option.rawValue)
                        .font(DD.Fonts.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(theme == option ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(theme == option ? DD.Colors.accentWin : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }
}
