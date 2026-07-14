import SwiftUI
import StoreKit

/// The upgrade screen. Best-in-class pattern: hero, tight value props, a vertical
/// plan selector with the annual plan pre-selected and badged (effective monthly
/// price shown), then a single clear CTA. Restore / Terms / Privacy sit quiet at
/// the bottom. Warm, never a hard sell; prices come live from StoreKit.
struct PaywallView: View {
    @Environment(PremiumStore.self) private var premium
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Product?
    @State private var busy = false

    // Replace the privacy URL with the real one before App Store submission.
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyURL = URL(string: "https://dinkdiary.app/privacy")!

    private let features: [(icon: String, text: String)] = [
        ("infinity", "Every session you've ever played"),
        ("chart.bar.fill", "Every insight, always"),
        ("person.2.fill", "Per-partner deep stats"),
        ("icloud.fill", "iCloud sync across your devices"),
    ]

    private var annual: Product? {
        premium.products.first { $0.subscription?.subscriptionPeriod.unit == .year }
    }
    private var monthly: Product? {
        premium.products.first { $0.subscription?.subscriptionPeriod.unit == .month }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                if premium.isPremium {
                    premiumState
                } else {
                    ScrollView {
                        VStack(spacing: DD.Spacing.gutter) {
                            hero
                            featureList
                            planSelector
                            callToAction
                            legalRow
                        }
                        .padding(.horizontal, DD.Spacing.gutter)
                        .padding(.top, DD.Spacing.cardGap)
                        .padding(.bottom, DD.Spacing.gutter)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(Font.system(size: 15, weight: .semibold))
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                }
            }
            .task {
                await premium.loadProducts()
                if selected == nil { selected = annual ?? premium.products.first }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [DD.Colors.gradientTop, DD.Colors.surface],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            ZStack {
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 96, height: 96)
                    .blur(radius: 36)
                    .opacity(0.35)
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 76, height: 76)
                Image(systemName: "trophy.fill")
                    .font(Font.system(size: 34, weight: .bold))
                    .foregroundStyle(DD.Colors.surface)
            }
            .padding(.top, DD.Spacing.rowGap)

            VStack(spacing: DD.Spacing.rowGap) {
                Text("Dink Diary Premium")
                    .font(DD.Fonts.largeTitle)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Your whole pickleball life, kept.")
                    .font(DD.Fonts.body)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            ForEach(features, id: \.text) { feature in
                HStack(spacing: DD.Spacing.cardGap) {
                    Image(systemName: feature.icon)
                        .font(Font.system(size: 16, weight: .semibold))
                        .foregroundStyle(DD.Colors.accentWin)
                        .frame(width: 26)
                    Text(feature.text)
                        .font(DD.Fonts.body)
                        .foregroundStyle(DD.Colors.textPrimary)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: Plan selector

    private var planSelector: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            if premium.products.isEmpty {
                ProgressView()
                    .tint(DD.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(DD.Spacing.gutter)
            } else {
                if let annual {
                    planCard(annual, badge: savingsBadge, subtitle: perMonthText(annual))
                }
                if let monthly {
                    planCard(monthly, badge: nil, subtitle: "Billed monthly")
                }
            }
        }
    }

    private func planCard(_ product: Product, badge: String?, subtitle: String) -> some View {
        let isSelected = selected?.id == product.id
        return Button {
            withAnimation(.easeOut(duration: DD.Motion.navFade)) { selected = product }
        } label: {
            HStack(spacing: DD.Spacing.cardGap) {
                selectionDot(isSelected)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: DD.Spacing.rowGap) {
                        Text(planName(product))
                            .font(DD.Fonts.headline)
                            .foregroundStyle(DD.Colors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(DD.Fonts.caption)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .foregroundStyle(DD.Colors.surface)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(DD.Colors.accentWin, in: Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                Spacer(minLength: 0)
                Text(product.displayPrice)
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
            }
            .padding(DD.Spacing.cardPadding)
            .background(
                (isSelected ? DD.Colors.accentWin.opacity(0.08) : DD.Colors.surfaceElevated),
                in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DD.Radius.sessionCard, style: .continuous)
                    .strokeBorder(isSelected ? DD.Colors.accentWin : DD.Colors.hairline, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func selectionDot(_ isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? DD.Colors.accentWin : DD.Colors.textSecondary, lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 12, height: 12)
            }
        }
    }

    // MARK: CTA

    private var callToAction: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Button {
                Task { await buy() }
            } label: {
                Text(busy ? "Just a moment..." : "Start Premium")
                    .font(DD.Fonts.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(DDPillButtonStyle(variant: .primary))
            .disabled(busy || selected == nil)

            Text(finePrint)
                .font(DD.Fonts.caption)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var legalRow: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            Button {
                Task { busy = true; await premium.restore(); busy = false }
            } label: {
                Text("Restore")
            }
            .buttonStyle(.plain)
            Link("Terms", destination: termsURL)
            Link("Privacy", destination: privacyURL)
        }
        .font(DD.Fonts.footnote)
        .foregroundStyle(DD.Colors.textSecondary)
        .padding(.top, DD.Spacing.rowGap)
    }

    private var premiumState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            ZStack {
                Circle().fill(DD.Colors.accentWin).frame(width: 88, height: 88).blur(radius: 34).opacity(0.35)
                Image(systemName: "checkmark.seal.fill")
                    .font(Font.system(size: 72, weight: .bold))
                    .foregroundStyle(DD.Colors.accentWin)
            }
            Text("You're all in.")
                .font(DD.Fonts.largeTitle)
                .foregroundStyle(DD.Colors.textPrimary)
            Text("Every session, every insight, every court is yours.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
            PillButton(title: "Done") { dismiss() }
                .padding(.top, DD.Spacing.cardGap)
        }
        .padding(DD.Spacing.gutter)
    }

    // MARK: Actions and formatting

    private func buy() async {
        guard let product = selected else { return }
        busy = true
        let success = await premium.purchase(product)
        busy = false
        if success { dismiss() }
    }

    private func planName(_ product: Product) -> String {
        switch product.subscription?.subscriptionPeriod.unit {
        case .year: return "Annual"
        case .month: return "Monthly"
        default: return product.displayName
        }
    }

    private func perMonthText(_ annual: Product) -> String {
        let perMonth = annual.price / 12
        return "\(perMonth.formatted(annual.priceFormatStyle)) / month, billed yearly"
    }

    private var savingsBadge: String? {
        guard let annual, let monthly else { return "Best value" }
        let annualDouble = NSDecimalNumber(decimal: annual.price).doubleValue
        let monthlyYearDouble = NSDecimalNumber(decimal: monthly.price).doubleValue * 12
        guard monthlyYearDouble > 0 else { return "Best value" }
        let saved = Int((1 - annualDouble / monthlyYearDouble) * 100)
        return saved > 0 ? "Save \(saved)%" : "Best value"
    }

    private var finePrint: String {
        guard let product = selected else {
            return "Auto-renews. Cancel anytime. Scoring is free forever."
        }
        return "\(product.displayPrice) \(planName(product) == "Annual" ? "per year" : "per month"), auto-renews. Cancel anytime. Scoring is free forever."
    }
}
