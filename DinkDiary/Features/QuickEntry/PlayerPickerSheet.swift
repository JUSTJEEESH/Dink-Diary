import SwiftUI
import SwiftData

/// Pick players (single or multiple) with inline creation. New names become
/// Player records immediately so the roster grows as you log.
struct PlayerPickerSheet: View {
    let title: String
    var allowsMultiple = false
    var maxSelection: Int? = nil
    var initiallySelected: [Player] = []
    let onDone: ([Player]) -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var players: [Player]

    @State private var selectedIDs: Set<UUID> = []
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.rowGap) {
                    newPlayerField

                    if players.isEmpty {
                        Text("No people yet. Add the folks you played with.")
                            .font(DD.Fonts.body)
                            .foregroundStyle(DD.Colors.textSecondary)
                            .padding(.top, DD.Spacing.gutter)
                    } else {
                        ForEach(players) { player in
                            Button {
                                toggle(player)
                            } label: {
                                playerRow(player)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(DD.Spacing.gutter)
            }
            .background(DD.Colors.surface)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { finish() }
                        .foregroundStyle(DD.Colors.accentWin)
                }
            }
            .onAppear { selectedIDs = Set(initiallySelected.map(\.remoteID)) }
        }
    }

    private var newPlayerField: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            TextField("New player", text: $newName)
                .textFieldStyle(.plain)
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textPrimary)
            Button("Add") { addPlayer() }
                .font(DD.Fonts.headline)
                .foregroundStyle(canAdd ? DD.Colors.accentWin : DD.Colors.textSecondary)
                .disabled(!canAdd)
        }
        .padding(DD.Spacing.cardPadding)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
        )
    }

    private func playerRow(_ player: Player) -> some View {
        HStack(spacing: DD.Spacing.cardGap) {
            AvatarView(
                initials: player.initials,
                tint: DD.Colors.avatarTint(seed: player.tintSeed),
                size: 32,
                ringColor: DD.Colors.surfaceElevated
            )
            Text(player.name)
                .font(DD.Fonts.headline)
                .foregroundStyle(DD.Colors.textPrimary)
            Spacer()
            if selectedIDs.contains(player.remoteID) {
                Image(systemName: "checkmark")
                    .font(Font.system(size: 15, weight: .bold))
                    .foregroundStyle(DD.Colors.accentWin)
            }
        }
        .padding(DD.Spacing.cardPadding)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
        )
    }

    private var canAdd: Bool {
        !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addPlayer() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let player = Player(name: name)
        context.insert(player)
        newName = ""
        if allowsMultiple {
            if maxSelection == nil || selectedIDs.count < maxSelection! {
                selectedIDs.insert(player.remoteID)
            }
        } else {
            selectedIDs = [player.remoteID]
        }
    }

    private func toggle(_ player: Player) {
        if allowsMultiple {
            if selectedIDs.contains(player.remoteID) {
                selectedIDs.remove(player.remoteID)
            } else if maxSelection == nil || selectedIDs.count < maxSelection! {
                selectedIDs.insert(player.remoteID)
            }
        } else {
            selectedIDs = [player.remoteID]
            finish()
        }
    }

    private func finish() {
        let chosen = players.filter { selectedIDs.contains($0.remoteID) }
        onDone(chosen)
        dismiss()
    }
}
