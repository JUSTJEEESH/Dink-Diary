import SwiftUI

/// Your people. M0: empty state; the partner grid arrives with the data model.
struct PeopleHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                VStack(spacing: DD.Spacing.cardGap) {
                    AvatarCluster(members: [])
                }
                .padding(DD.Spacing.gutter)
            }
            .navigationTitle("Your people")
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }
}
