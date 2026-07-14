import Foundation
import SwiftData

/// A place you play. Auto-created from location later (M4); nameable by hand now.
@Model
final class Court {
    var remoteID: UUID = UUID()
    var name: String = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var createdAt: Date = Date.now

    @Relationship(inverse: \Session.court) var sessions: [Session]? = nil

    init(name: String = "") {
        self.remoteID = UUID()
        self.name = name
        self.createdAt = .now
    }
}
