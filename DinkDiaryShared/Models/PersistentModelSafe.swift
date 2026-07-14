import SwiftData

extension PersistentModel {
    /// True while the model still has live backing data. Reading a persistent
    /// property of a deleted/invalidated model is a fatal error, so views guard
    /// relationship targets (e.g. a game's partner) with this before reading them.
    var isAlive: Bool {
        !isDeleted && modelContext != nil
    }
}
