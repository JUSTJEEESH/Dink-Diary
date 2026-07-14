import Foundation

/// A life moment worth celebrating, computed from your history. Never a badge for
/// a badge's sake, always a real thing that happened, told with a little humor.
/// `headline` is the big line, `caption` the warm/funny subtitle, `detail` an
/// optional bit of context ("over Dave Lopez"). `tint` is a role the UI maps to
/// a palette color; the model stays Foundation-only.
struct Milestone: Identifiable, Equatable {
    enum Tint {
        case win, streak, rivalry, people, courts, special, neutral
    }

    let id: String
    let headline: String
    let caption: String
    var detail: String? = nil
    let symbol: String
    let tint: Tint
    let achievedAt: Date

    static func == (lhs: Milestone, rhs: Milestone) -> Bool { lhs.id == rhs.id }
}
