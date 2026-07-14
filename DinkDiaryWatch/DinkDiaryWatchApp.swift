import SwiftUI

@main
struct DinkDiaryWatchApp: App {
    @State private var store = WatchSessionStore()

    var body: some Scene {
        WindowGroup {
            WatchRootView(store: store)
        }
    }
}
