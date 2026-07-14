import Foundation
import StoreKit
import Observation

/// Premium entitlement via StoreKit 2. `isPremium` is derived from the current
/// entitlements, kept live by a transaction listener. Testable against the
/// bundled Products.storekit configuration with no App Store Connect setup.
@MainActor
@Observable
final class PremiumStore {
    static let shared = PremiumStore()

    // Product IDs match Products.storekit. For App Store Connect, register these
    // same identifiers (or update both here and the config together).
    static let annualID = "com.joshgreendesign.dinkdiary.premium.annual"
    static let monthlyID = "com.joshgreendesign.dinkdiary.premium.monthly"
    static var productIDs: [String] { [annualID, monthlyID] }

    /// Free-tier history cap; premium is unlimited.
    static let freeSessionLimit = 10
    /// Number of insights the free tier shows before the locked state.
    static let freeInsightLimit = 3

    private(set) var products: [Product] = []
    private(set) var isPremium = false

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlement()
            }
        }
        Task { await refresh() }
    }

    func refresh() async {
        await loadProducts()
        await refreshEntitlement()
    }

    func loadProducts() async {
        let loaded = (try? await Product.products(for: Self.productIDs)) ?? []
        // Annual (higher price) first.
        products = loaded.sorted { $0.price > $1.price }
    }

    /// Returns true when the purchase completed and premium is now active.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        guard let result = try? await product.purchase() else { return false }
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlement()
            }
            return isPremium
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPremium = active
    }

    #if DEBUG
    /// Preview the gated states without going through the purchase flow.
    func debugSetPremium(_ value: Bool) { isPremium = value }
    #endif
}
