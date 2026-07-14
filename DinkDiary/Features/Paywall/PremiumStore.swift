import Foundation
import Observation

/// Tracks whether premium is unlocked. M5 scaffold: persisted in UserDefaults so
/// the free-tier locked states are real and previewable. M6 replaces the guts
/// with StoreKit 2 (products, purchase, entitlement listener) without changing
/// this surface, so the gates that read `isPremium` don't move.
@Observable
final class PremiumStore {
    static let shared = PremiumStore()

    private let key = "dd.premium.unlocked"

    var isPremium: Bool {
        didSet { UserDefaults.standard.set(isPremium, forKey: key) }
    }

    private init() {
        isPremium = UserDefaults.standard.bool(forKey: key)
    }

    /// Free-tier history cap; premium is unlimited.
    static let freeSessionLimit = 10
    /// Number of insights the free tier shows before the locked state.
    static let freeInsightLimit = 3

    /// Temporary until M6: unlock to preview the full experience.
    func unlockForNow() { isPremium = true }
    func resetToFree() { isPremium = false }
}
