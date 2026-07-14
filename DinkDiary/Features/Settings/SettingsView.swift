import SwiftUI

/// Set the default game format once; it's what new games use everywhere.
struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @State private var kitchenTaps = 0

    /// How many taps into the hidden kitchen the reader has gone. The last line
    /// stays put once revealed; earlier taps just do nothing visible.
    private var kitchenSecret: String? {
        let revealed = kitchenTaps - 6
        guard revealed >= 1 else { return nil }
        return Quips.kitchenSecret[min(revealed, Quips.kitchenSecret.count) - 1]
    }

    var body: some View {
        @Bindable var settings = settings
        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.gutter) {
                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Your name").ddCaption()
                        TextField("First name", text: $settings.playerName)
                            .textContentType(.givenName)
                            .autocorrectionDisabled()
                            .font(DD.Fonts.headline)
                            .foregroundStyle(DD.Colors.textPrimary)
                            .padding(.horizontal, DD.Spacing.cardPadding)
                            .padding(.vertical, 12)
                            .background(DD.Colors.surfaceElevated, in: Capsule())
                        Text("Just to warm up your home screen. It stays on your device.")
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(DD.Colors.textSecondary)
                    }

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

                    Spacer(minLength: DD.Spacing.gutter)

                    // The kitchen. Tap the line a few times to find it.
                    Text("Dink Diary")
                        .font(DD.Fonts.caption)
                        .foregroundStyle(DD.Colors.textSecondary.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if kitchenTaps < 6 + Quips.kitchenSecret.count { kitchenTaps += 1 }
                        }
                    if let secret = kitchenSecret {
                        Text(secret)
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(DD.Colors.kitchenGreen)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: DD.Motion.navFade), value: kitchenTaps)
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
