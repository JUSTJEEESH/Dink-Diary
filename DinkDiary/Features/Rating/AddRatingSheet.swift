import SwiftUI
import SwiftData

/// Log a DUPR rating snapshot: the value, whether it's doubles or singles, and
/// the date you saw it. Dink Diary only remembers what you enter.
struct AddRatingSheet: View {
    var isSingles: Bool = false
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var singles = false
    @State private var date = Date.now
    @State private var didSeed = false

    private var parsed: Double? { Double(text.trimmingCharacters(in: .whitespaces)) }
    private var isValid: Bool {
        guard let value = parsed else { return false }
        return value >= 1.0 && value <= 9.0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.gutter) {
                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Rating").ddCaption()
                        TextField("3.500", text: $text)
                            .keyboardType(.decimalPad)
                            .font(DD.Fonts.statMedium)
                            .foregroundStyle(DD.Colors.textPrimary)
                            .padding(.horizontal, DD.Spacing.cardPadding)
                            .padding(.vertical, 12)
                            .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous))
                        Text("Your DUPR rating, as you saw it. Between 1.0 and 9.0.")
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(DD.Colors.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Format").ddCaption()
                        Picker("Format", selection: $singles) {
                            Text("Doubles").tag(false)
                            Text("Singles").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Date").ddCaption()
                        DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(DD.Colors.accentWin)
                    }

                    PillButton(title: "Save rating") { save() }
                        .disabled(!isValid)
                        .opacity(isValid ? 1 : 0.5)
                }
                .padding(DD.Spacing.gutter)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Log a rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
            .onAppear {
                guard !didSeed else { return }
                didSeed = true
                singles = isSingles
            }
        }
    }

    private func save() {
        guard let value = parsed, isValid else { return }
        let entry = RatingEntry(value: value, isSingles: singles, recordedAt: date)
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
