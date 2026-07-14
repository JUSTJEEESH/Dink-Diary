import Foundation
import SwiftData

/// A snapshot of your DUPR rating on a date. Display only: Dink Diary never
/// computes a rating, it just remembers the ones you enter so you can see them
/// over time. CloudKit-safe: defaults on every property, no relationships.
@Model
final class RatingEntry {
    var remoteID: UUID = UUID()
    /// The DUPR value, e.g. 3.847.
    var value: Double = 0
    /// false = doubles (the common one), true = singles.
    var isSingles: Bool = false
    var recordedAt: Date = Date.now

    init(value: Double = 0, isSingles: Bool = false, recordedAt: Date = .now) {
        self.remoteID = UUID()
        self.value = value
        self.isSingles = isSingles
        self.recordedAt = recordedAt
    }
}
