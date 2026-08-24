import Foundation
import Observation
import StoreKit

@Observable
@MainActor
final class EntitlementManager {
    enum ProductID {
        static let lifetime = "com.civipass.app.lifetime"
        static let monthly = "com.civipass.app.premium.monthly"
        static let yearly = "com.civipass.app.premium.yearly"

        static let all: [String] = [lifetime, monthly, yearly]
    }

    enum StoreError: Error {
        case failedVerification
    }

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoadingProducts = false
    var errorMessage: String?

    private var transactionListenerTask: Task<Void, Never>?

    /// True once the user holds any unlocking purchase — lifetime, or an active monthly/yearly subscription.
    var hasPremiumAccess: Bool {
        !purchasedProductIDs.isEmpty
    }

    init() {
        transactionListenerTask = listenForTransactionUpdates()
        Task {
            await updateEntitlements()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: ProductID.all)
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load products: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateEntitlements()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateEntitlements()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    /// Rebuilds `purchasedProductIDs` from Transaction.currentEntitlements — the source of
    /// truth for "what does this user currently have access to" (already excludes expired
    /// subscriptions and revoked/refunded purchases).
    func updateEntitlements() async {
        var activeProductIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                activeProductIDs.insert(transaction.productID)
            }
        }
        purchasedProductIDs = activeProductIDs
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? self.checkVerified(result) else { continue }
                await self.updateEntitlements()
                await transaction.finish()
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
