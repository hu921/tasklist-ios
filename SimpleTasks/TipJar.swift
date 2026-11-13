import Foundation
import StoreKit
import Observation

/// Optional tips through Apple In-App Purchase. Nothing is unlocked.
/// The three tips must be created in App Store Connect with these product IDs
/// (type: Consumable). Until they exist, the tip section stays hidden.
@Observable
final class TipJar {
    static let shared = TipJar()
    static let productIDs = [
        "com.hu921.simpletasks.tip.small",
        "com.hu921.simpletasks.tip.medium",
        "com.hu921.simpletasks.tip.large",
    ]

    var products: [Product] = []
    var isBuying = false
    /// Shown under the tip buttons after a tip, or after an error.
    var message: String?

    @ObservationIgnored private var updates: Task<Void, Never>?

    /// Loads the tips and finishes any tip that was paid while the app was closed.
    func start() async {
        if updates == nil {
            updates = Task.detached {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        await transaction.finish()
                    }
                }
            }
        }
        guard products.isEmpty else { return }
        do {
            let loaded = try await Product.products(for: Self.productIDs)
            let sorted = loaded.sorted { $0.price < $1.price }
            await MainActor.run { products = sorted }
            AppLog.log("tips loaded", "\(sorted.count)")
        } catch {
            AppLog.error("tips load failed", error)
        }
    }

    @MainActor
    func buy(_ product: Product) async {
        isBuying = true
        message = nil
        defer { isBuying = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                message = "Thank you for your support!"
                AppLog.log("tip ok", product.id)
            case .success(.unverified(_, let error)):
                message = "The tip could not be confirmed."
                AppLog.error("tip unverified", error)
            case .pending:
                message = "Waiting for approval."
                AppLog.log("tip pending", product.id)
            case .userCancelled:
                AppLog.log("tip cancelled", product.id)
            @unknown default:
                break
            }
        } catch {
            message = "The tip did not go through."
            AppLog.error("tip failed", error)
        }
    }
}
