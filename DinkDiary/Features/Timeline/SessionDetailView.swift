import SwiftUI

/// Read view of a session. The trophy recap card that makes this the screenshot
/// artifact arrives in M4; for now it reuses the feed card plus the game list.
struct SessionDetailView: View {
    let session: Session

    private var games: [Game] { session.gamesInOrder }

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                SessionCardView(session: session)

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
    }
}
