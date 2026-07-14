import Foundation

/// A life moment worth celebrating, computed from your history. Never a badge for
/// a badge's sake, always a real thing that happened.
struct Milestone: Identifiable, Equatable {
    enum Kind: String {
        case games, sessions, courts, streak, partner, people
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let symbol: String
    let achievedAt: Date

    static func == (lhs: Milestone, rhs: Milestone) -> Bool { lhs.id == rhs.id }
}
