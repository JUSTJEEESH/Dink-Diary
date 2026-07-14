import SwiftData
import Foundation

/// Builds the app's ModelContainer. CloudKit sync is a premium feature: the
/// container is built with private-database mirroring only when premium was
/// active at launch (cached in UserDefaults), so a purchase turns sync on at the
/// next launch over the same local store. The models are CloudKit-safe (optional
/// relationships with inverses, defaults throughout, no unique constraints).
enum DataStore {
    static let schema = Schema([
        Player.self,
        Court.self,
        Session.self,
        Game.self,
    ])

    /// Cached premium flag PremiumStore writes; read here to decide sync at launch.
    static let premiumCacheKey = "dd.premium.cached"

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let syncEnabled = !inMemory && UserDefaults.standard.bool(forKey: premiumCacheKey)

        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase
        if syncEnabled {
            let containerID = "iCloud.\(Bundle.main.bundleIdentifier ?? "com.joshgreendesign.dinkdiary")"
            cloudKitDatabase = .private(containerID)
        } else {
            cloudKitDatabase = .none
        }

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: cloudKitDatabase
        )
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            // If CloudKit init fails (e.g. not signed into iCloud), fall back to local.
            let local = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
            if let container = try? ModelContainer(for: schema, configurations: local) {
                return container
            }
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
