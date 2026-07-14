import Foundation
import SwiftData

/// A person you play with or against. Local only in v1: no accounts, no social.
/// CloudKit-compatible: every stored property has a default, relationships are
/// optional with inverses, and identity travels on `remoteID` (not the
/// per-device persistentModelID) so watch payloads and future sync can upsert.
@Model
final class Player {
    var remoteID: UUID = UUID()
    var name: String = ""
    var isMe: Bool = false
    @Attribute(.externalStorage) var photoData: Data? = nil
    var createdAt: Date = Date.now

    @Relationship(inverse: \Game.myPartner) var gamesAsPartner: [Game]? = nil
    @Relationship(inverse: \Game.opponents) var gamesAsOpponent: [Game]? = nil

    init(name: String = "", isMe: Bool = false) {
        self.remoteID = UUID()
        self.name = name
        self.isMe = isMe
        self.createdAt = .now
    }

    /// Up to two uppercase initials, e.g. "Sarah Miller" -> "SM".
    var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    /// Stable per-player seed for avatar tinting (UUID.hashValue is not stable
    /// across launches, so derive from the raw bytes instead).
    var tintSeed: Int {
        withUnsafeBytes(of: remoteID.uuid) { bytes in
            bytes.reduce(0) { $0 + Int($1) }
        }
    }
}
