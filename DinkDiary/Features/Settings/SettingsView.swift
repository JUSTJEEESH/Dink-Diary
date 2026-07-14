import SwiftUI

/// Set the default game format once; it's what new games use everywhere.
struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.gutter) {
                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Scoring").ddCaption()
                        segmented(
                            options: ScoringType.allCases.map { ($0.label, $0) },
                            selection: settings.scoringType,
                            set: { settings.scoringType = $0 }
                        )
                    }

                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Games to").ddCaption()
                        segmented(
                            options: GameFormat.targetOptions.map { ("\($0)", $0) },
                            selection: settings.targetPoints,
                            set: { settings.targetPoints = $0 }
                        )
                    }

                    Text("Win by \(settings.winBy). New games use this format; you can change it per game as you log.")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(DD.Spacing.gutter)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DD.Colors.accentWin)
                }
            }
        }
    }

    private func segmented<T: Equatable>(options: [(String, T)], selection: T, set: @escaping (T) -> Void) -> some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { title, value in
                Button {
                    set(value)
                } label: {
                    Text(title)
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selection == value ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(selection == value ? DD.Colors.accentWin : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }
}
