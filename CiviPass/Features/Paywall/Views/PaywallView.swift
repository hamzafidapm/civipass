import SwiftUI
import StoreKit

/// Shown inline in place of locked content (not presented modally) — StudyView swaps
/// this in for its content area, so it has no navigation chrome of its own.
struct PaywallView: View {
    @Environment(EntitlementManager.self) private var entitlementManager
    @State private var purchasingProductID: String?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                VStack(spacing: CPSpacing.sm) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(CPColor.brandAccent)
                    Text("Unlock Full Access")
                        .font(CPTypography.largeTitle)
                    Text("Get every American History and Integrated Civics question, plus mock tests across all categories.")
                        .font(CPTypography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, CPSpacing.lg)

                if entitlementManager.isLoadingProducts {
                    ProgressView()
                        .padding(.vertical, CPSpacing.lg)
                } else if entitlementManager.products.isEmpty {
                    Text("Purchase options aren't available right now. Please try again later.")
                        .font(CPTypography.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: CPSpacing.sm) {
                        ForEach(sortedProducts) { product in
                            ProductOptionButton(
                                product: product,
                                isPurchasing: purchasingProductID == product.id
                            ) {
                                purchase(product)
                            }
                            .disabled(purchasingProductID != nil)
                        }
                    }
                }

                if let errorMessage = entitlementManager.errorMessage {
                    Text(errorMessage)
                        .font(CPTypography.caption)
                        .foregroundStyle(CPColor.danger)
                        .multilineTextAlignment(.center)
                }

                Button("Restore Purchases") {
                    Task { await entitlementManager.restorePurchases() }
                }
                .font(CPTypography.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(CPSpacing.lg)
        }
        .task {
            await entitlementManager.loadProducts()
        }
    }

    private var sortedProducts: [Product] {
        entitlementManager.products.sorted { order(of: $0) < order(of: $1) }
    }

    private func order(of product: Product) -> Int {
        switch product.id {
        case EntitlementManager.ProductID.monthly: return 0
        case EntitlementManager.ProductID.yearly: return 1
        case EntitlementManager.ProductID.lifetime: return 2
        default: return 3
        }
    }

    private func purchase(_ product: Product) {
        purchasingProductID = product.id
        Task {
            await entitlementManager.purchase(product)
            purchasingProductID = nil
        }
    }
}

private struct ProductOptionButton: View {
    let product: Product
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: CPSpacing.xs) {
                    Text(title)
                        .font(CPTypography.body.bold())
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(CPTypography.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .font(CPTypography.body.bold())
                        .foregroundStyle(CPColor.brandPrimary)
                }
            }
            .padding(CPSpacing.md)
            .background(CPColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch product.id {
        case EntitlementManager.ProductID.lifetime: return "Lifetime Unlock"
        case EntitlementManager.ProductID.monthly: return "Monthly"
        case EntitlementManager.ProductID.yearly: return "Yearly"
        default: return product.displayName
        }
    }

    private var subtitle: String? {
        switch product.id {
        case EntitlementManager.ProductID.lifetime: return "Pay once, unlock forever"
        case EntitlementManager.ProductID.monthly: return "Billed monthly, cancel anytime"
        case EntitlementManager.ProductID.yearly: return "Best value — billed yearly"
        default: return nil
        }
    }
}

#Preview {
    PaywallView()
        .environment(EntitlementManager())
}
