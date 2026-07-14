import SwiftUI

@main
struct DinkDiaryApp: App {
    let container = DataStore.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
