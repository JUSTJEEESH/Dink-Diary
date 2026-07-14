import SwiftUI

/// Read view of a session, led by the trophy recap card (the screenshot artifact)
/// followed by the game list.
struct SessionDetailView: View {
    let session: Session
    @State private var showingShare = false

    private var games: [Game] { session.gamesInOrder }

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                TrophyRecapCard(session: session)

                ForEach(games) { game in
                    GameRowView(game: game)
                }
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.top, DD.Spacing.rowGap)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundStyle(DD.Colors.accentWin)
                .disabled(games.isEmpty)
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareCardSheet(session: session)
        }
    }
}
