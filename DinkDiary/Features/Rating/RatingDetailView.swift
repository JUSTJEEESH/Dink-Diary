import SwiftUI
import SwiftData
import Charts

/// Your DUPR rating over time: a trend line and the history of what you've
/// logged. Display only, never a judgment; a dip is just a data point.
struct RatingDetailView: View {
    @Query(sort: \RatingEntry.recordedAt) private var entries: [RatingEntry]
    @Environment(\.modelContext) private var context

    @State private var singles = false
    @State private var showingAdd = false

    private var series: [RatingEntry] {
        entries.filter { $0.isSingles == singles }
    }
    private var latest: RatingEntry? { series.last }
    private var first: RatingEntry? { series.first }
    private var delta: Double? {
        guard let latest, let first, latest.remoteID != first.remoteID else { return nil }
        return latest.value - first.value
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                Picker("Format", selection: $singles) {
                    Text("Doubles").tag(false)
                    Text("Singles").tag(true)
                }
                .pickerStyle(.segmented)

                if series.isEmpty {
                    emptyState
                } else {
                    header
                    chart
                    history
                }

                PillButton(title: "Log a rating") { showingAdd = true }
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.top, DD.Spacing.rowGap)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle("Your rating")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAdd) {
            AddRatingSheet(isSingles: singles)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.cardGap) {
            Text(latest.map { format($0.value) } ?? "--")
                .font(DD.Fonts.statLarge)
                .foregroundStyle(DD.Colors.textPrimary)
            if let delta {
                Text(deltaText(delta))
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(delta >= 0 ? DD.Colors.accentWin : DD.Colors.textSecondary)
            }
            Spacer()
            Text("DUPR \u{00B7} display only")
                .font(DD.Fonts.caption)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private var chart: some View {
        Chart(series) { entry in
            LineMark(
                x: .value("Date", entry.recordedAt),
                y: .value("Rating", entry.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(DD.Colors.accentWin)

            PointMark(
                x: .value("Date", entry.recordedAt),
                y: .value("Rating", entry.value)
            )
            .foregroundStyle(DD.Colors.accentWin)
        }
        .chartYScale(domain: yDomain)
        .frame(height: 220)
        .padding(DD.Spacing.cardPadding)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }

    private var yDomain: ClosedRange<Double> {
        let values = series.map(\.value)
        guard let low = values.min(), let high = values.max() else { return 2...5 }
        let pad = max(0.15, (high - low) * 0.3)
        return (low - pad)...(high + pad)
    }

    private var history: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            ForEach(series.reversed()) { entry in
                HStack {
                    Text(format(entry.value))
                        .font(DD.Fonts.headline)
                        .foregroundStyle(DD.Colors.textPrimary)
                    Spacer()
                    Text(entry.recordedAt.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                    Button(role: .destructive) {
                        context.delete(entry)
                        try? context.save()
                    } label: {
                        Image(systemName: "trash")
                            .font(Font.system(size: 14, weight: .semibold))
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                    .padding(.leading, DD.Spacing.rowGap)
                }
                .padding(DD.Spacing.cardPadding)
                .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            Image(systemName: "chart.xyaxis.line")
                .font(Font.system(size: 26, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
            Text("Log your DUPR to watch it over time.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DD.Spacing.gutter)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.3f", value)
    }

    private func deltaText(_ delta: Double) -> String {
        let sign = delta >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.3f", delta)) since you started tracking"
    }
}
