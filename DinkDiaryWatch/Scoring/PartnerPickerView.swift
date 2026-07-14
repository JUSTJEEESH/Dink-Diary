import SwiftUI

/// The 10-second moment, matched to the mock: "Who was your partner?" over a
/// grid of large tinted faces, recents first, one tap logs the game. The last
/// tile is New for a name that isn't in the roster yet.
struct PartnerPickerView: View {
    let roster: [RosterPlayer]
    var onPick: (RosterPlayer?) -> Void

    @State private var showingNew = false
    @State private var newName = ""

    private let columns = [GridItem(.adaptive(minimum: 56), spacing: DD.Spacing.cardGap)]

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Who was your partner?")
                    .font(DD.Fonts.title3)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: columns, spacing: DD.Spacing.cardGap) {
                    ForEach(roster.prefix(5)) { player in
                        Button {
                            onPick(player)
                        } label: {
                            face(player)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showingNew = true
                    } label: {
                        newTile
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
        .sheet(isPresented: $showingNew) {
            NewPlayerEntry(name: $newName) {
                let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                showingNew = false
                newName = ""
                if !trimmed.isEmpty {
                    onPick(RosterPlayer(id: UUID(), name: trimmed))
                }
            }
        }
    }

    private func face(_ player: RosterPlayer) -> some View {
        let tint = DD.Colors.avatarTint(seed: player.tintSeed)
        return VStack(spacing: 4) {
            Text(player.initials)
                .font(Font.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 56, height: 56)
                .background(tint.opacity(0.22), in: Circle())
            Text(player.name.split(separator: " ").first.map(String.init) ?? player.name)
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textPrimary)
                .lineLimit(1)
        }
    }

    private var newTile: some View {
        VStack(spacing: 4) {
            Image(systemName: "plus")
                .font(Font.system(size: 22, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
                .frame(width: 56, height: 56)
                .background(DD.Colors.surfaceElevated, in: Circle())
            Text("New")
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }
}

/// Minimal name entry for a partner not in the roster. On the watch the text
/// field opens scribble/dictation.
private struct NewPlayerEntry: View {
    @Binding var name: String
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Text("New player").ddCaption()
            TextField("Name", text: $name)
                .font(DD.Fonts.headline)
                .foregroundStyle(DD.Colors.textPrimary)
            Button(action: onDone) {
                Text("Add")
                    .font(DD.Fonts.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(DDPillButtonStyle(variant: .primary))
        }
        .padding(DD.Spacing.cardGap)
        .background(DD.Colors.watchCanvas)
    }
}
