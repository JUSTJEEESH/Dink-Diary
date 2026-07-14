import SwiftUI

@main
struct DinkDiaryApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container = DataStore.makeContainer()

    init() {
        PhoneConnectivityManager.shared.start(container: container)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
                .environment(PremiumStore.shared)
                .environment(SettingsStore.shared)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            // Keep the watch's partner grid current with people added on the phone.
            if phase == .active {
                PhoneConnectivityManager.shared.sendCurrentRoster()
            }
        }
    }
}
