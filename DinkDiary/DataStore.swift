import SwiftData

/// Builds the app's ModelContainer. CloudKit stays off (`.none`) until the
/// premium milestone (M6); the same store URL is reused when it flips on, so
/// mirroring adopts existing data without migration.
enum DataStore {
    static let schema = Schema([
        Player.self,
        Court.self,
        Session.self,
        Game.self,
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
