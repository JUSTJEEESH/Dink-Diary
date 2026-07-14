import SwiftUI
import StoreKit

/// The upgrade screen: what premium unlocks, the two subscription options, and
/// restore. Warm, never a hard sell; prices come live from StoreKit.
struct PaywallView: View {
    @Environment(PremiumStore.self) private var premium
    @Environment(\.dismiss) private var dismiss
    @State private var busy = false

    private let features = [
        "Every session you've ever played",
        "Every insight, always",
        "Per-partner deep stats",
        "Custom share card themes",
        "CSV export",
        "iCloud sync across your devices",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                    if premium.isPremium {
                        premiumState
                    } else {
                        pitch
                        featureList
                        productButtons
                        restoreButton
                        finePrint
                    }
                }
                .padding(DD.Spacing.gutter)
                .padding(.bottom, 40)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
            .task { await premium.loadProducts() }
        }
    }

    private var pitch: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text("Dink Diary Premium")
                .font(DD.Fonts.largeTitle)
                .foregroundStyle(DD.Colors.textPrimary)
            Text("Your whole pickleball life, kept.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            ForEach(features, id: \.self) { feature in
                HStack(spacing: DD.Spacing.cardGap) {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 14, weight: .bold))
                        .foregroundStyle(DD.Colors.accentWin)
                        .frame(width: 20)
                    Text(feature)
                        .font(DD.Fonts.body)
                        .foregroundStyle(DD.Colors.textPrimary)
                }
            }
        }
        .padding(.vertical, DD.Spacing.rowGap)
    }

    private var productButtons: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            if premium.products.isEmpty {
                Text("Loading options...")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
            } else {
                ForEach(premium.products, id: \.id) { product in
                    Button {
                        Task { await buy(product) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.displayName)
                                    .font(DD.Fonts.headline)
                                Text(periodText(product))
                                    .font(DD.Fonts.caption)
                                    .foregroundStyle(DD.Colors.surface.opacity(0.7))
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .font(DD.Fonts.headline)
                        }
                        .padding(.horizontal, DD.Spacing.cardPadding)
                        .frame(height: 54)
                    }
                    .buttonStyle(DDPillButtonStyle(variant: .primary))
                    .disabled(busy)
                }
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task { busy = true; await premium.restore(); busy = false }
        } label: {
            Text("Restore purchases")
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }

    private var finePrint: some View {
        Text("$24.99/year or $3.99/month. Cancel anytime; scoring stays free forever.")
            .font(DD.Fonts.caption)
            .foregroundStyle(DD.Colors.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var premiumState: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text("You're all in.")
                .font(DD.Fonts.largeTitle)
                .foregroundStyle(DD.Colors.accentWin)
            Text("Every session, every insight, every court is yours.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private func buy(_ product: Product) async {
        busy = true
        let success = await premium.purchase(product)
        busy = false
        if success { dismiss() }
    }

    private func periodText(_ product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        switch period.unit {
        case .year: return "Billed yearly"
        case .month: return "Billed monthly"
        case .week: return "Billed weekly"
        case .day: return "Billed daily"
        @unknown default: return ""
        }
    }
}
