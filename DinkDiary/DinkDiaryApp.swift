import SwiftUI
import SwiftData

@main
struct DinkDiaryApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container = DataStore.makeContainer()

    init() {
        PhoneConnectivityManager.shared.start(container: container)
        Task { await HealthEnricher.requestAuthorization() }
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
            guard phase == .active else { return }
            // Keep the watch's partner grid current with people added on the phone.
            PhoneConnectivityManager.shared.sendCurrentRoster()
            // Ask for location once so court/weather capture can work.
            LocationManager.shared.requestAuthorization()
            // Fill in health stats for any watch session whose workout has now synced.
            Task { await HealthEnricher.enrichPending(container: container) }
        }
    }
}
