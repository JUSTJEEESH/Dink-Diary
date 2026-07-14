import Foundation
import SwiftData

/// A place you play. Auto-created from location later (M4); nameable by hand now.
@Model
final class Court {
    var remoteID: UUID = UUID()
    var name: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    /// An optional court/crew photo, compressed. Becomes the card background.
    @Attribute(.externalStorage) var photoData: Data? = nil
    var createdAt: Date = Date.now

    @Relationship(inverse: \Session.court) var sessions: [Session]? = nil

    init(name: String = "") {
        self.remoteID = UUID()
        self.name = name
        self.createdAt = .now
    }
}
