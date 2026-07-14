import Foundation

/// Side-out (traditional) or rally scoring. Stored as a raw string on Game so
/// the schema stays CloudKit- and migration-safe.
enum ScoringType: String, Codable, CaseIterable, Identifiable {
    case sideOut
    case rally

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sideOut: return "Side Out"
        case .rally: return "Rally"
        }
    }
}
