import Foundation
import StoreKit

@MainActor
final class PremiumStore: ObservableObject {
    static let monthlyID = "it.migranote.premium.monthly"
    static let yearlyID = "it.migranote.premium.yearly"
    static let productIDs: Set<String> = [monthlyID, yearlyID]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published private(set) var message: String?

    init() {
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
        Task { await observeTransactions() }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs).sorted { $0.price < $1.price }
            if products.isEmpty {
                message = "I prodotti Premium non sono ancora configurati in App Store Connect."
            }
        } catch {
            message = "Non è stato possibile caricare gli abbonamenti."
        }
    }

    func purchase(_ product: Product) async {
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else {
                    message = "Acquisto non verificato."
                    return
                }
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled:
                break
            case .pending:
                message = "Acquisto in attesa di approvazione."
            @unknown default:
                message = "Esito dell'acquisto non riconosciuto."
            }
        } catch {
            message = "Acquisto non completato. Riprova."
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = isPremium ? "Abbonamento ripristinato." : "Non risultano acquisti da ripristinare."
        } catch {
            message = "Ripristino non riuscito."
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.productIDs.contains(transaction.productID),
                  transaction.revocationDate == nil else { continue }
            if let expiry = transaction.expirationDate, expiry <= Date() { continue }
            active = true
        }
        isPremium = active
    }

    private func observeTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }
}
