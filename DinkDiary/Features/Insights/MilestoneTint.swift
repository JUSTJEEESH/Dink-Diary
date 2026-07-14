import SwiftUI

/// Maps a milestone's tint role (model-side, Foundation-only) to a palette color.
extension Milestone.Tint {
    var color: Color {
        switch self {
        case .win: return DD.Colors.accentWin
        case .streak: return DD.Colors.streak
        case .rivalry: return DD.Colors.accentLoss
        case .people: return DD.Colors.courtBlue
        case .courts: return DD.Colors.kitchenGreen
        case .special: return DD.Colors.streak
        case .neutral: return DD.Colors.textPrimary
        }
    }
}
