import SwiftUI
import Charts

/// The DUPR summary on Insights: your current doubles rating, a small trend
/// sparkline, and the change since you started. Taps through to the full view.
/// If you've logged nothing, a quiet invitation to start.
struct RatingCard: View {
    /// Doubles entries, sorted oldest to newest.
    let entries: [RatingEntry]

    private var latest: RatingEntry? { entries.last }
    private var delta: Double? {
        guard let latest, let first = entries.first, entries.count > 1 else { return nil }
        return latest.value - first.value
    }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            if let latest {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your rating").ddCaption()
                    Text(String(format: "%.3f", latest.value))
                        .font(DD.Fonts.statMedium)
                        .foregroundStyle(DD.Colors.textPrimary)
                    if let delta {
                        Text("\(delta >= 0 ? "+" : "")\(String(format: "%.3f", delta))")
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(delta >= 0 ? DD.Colors.accentWin : DD.Colors.textSecondary)
                    } else {
                        Text("DUPR \u{00B7} doubles")
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                }
                Spacer()
                if entries.count > 1 {
                    sparkline.frame(width: 120, height: 48)
                }
                Image(systemName: "chevron.right")
                    .font(Font.system(size: 13, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            } else {
                Image(systemName: "chart.xyaxis.line")
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundStyle(DD.Colors.accentWin)
                    .frame(width: 44, height: 44)
                    .background(DD.Colors.accentWin.opacity(0.14), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add your DUPR")
                        .font(DD.Fonts.headline)
                        .foregroundStyle(DD.Colors.textPrimary)
                    Text("Track your rating over time.")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.system(size: 13, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }

    private var sparkline: some View {
        Chart(entries) { entry in
            LineMark(
                x: .value("Date", entry.recordedAt),
                y: .value("Rating", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(DD.Colors.accentWin)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: sparkDomain)
    }

    private var sparkDomain: ClosedRange<Double> {
        let values = entries.map(\.value)
        guard let low = values.min(), let high = values.max() else { return 2...5 }
        let pad = max(0.1, (high - low) * 0.25)
        return (low - pad)...(high + pad)
    }
}
