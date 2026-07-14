import Foundation

/// A face in the partner grid. In M2 this comes from a local placeholder roster;
/// M3 replaces it with the phone's real roster pushed over WatchConnectivity.
struct RosterPlayer: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String

    var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let result = String(letters).uppercased()
        return result.isEmpty ? "?" : result
    }

    var tintSeed: Int {
        withUnsafeBytes(of: id.uuid) { bytes in
            bytes.reduce(0) { $0 + Int($1) }
        }
    }
}

/// A game captured on the wrist. Stays local in M2; M3 sends it to the phone as
/// a sync payload the moment the partner is picked.
struct WatchGame: Identifiable, Codable {
    var id = UUID()
    var myScore: Int
    var theirScore: Int
    var mode: ScoringType
    var partnerID: UUID?
    var partnerName: String?
    var playedAt = Date()

    var didWin: Bool { myScore > theirScore }
}
