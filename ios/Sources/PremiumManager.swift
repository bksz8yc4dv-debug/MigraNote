import Foundation
import StoreKit
import Combine

@MainActor
final class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    static let monthlyID = "it.migranote.premium.monthly"
    static let annualID = "it.migranote.premium.annual"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published var message: String?
    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await observeTransactions() }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.monthlyID, Self.annualID])
                .sorted { $0.price < $1.price }
        } catch {
            message = "Non è stato possibile caricare gli abbonamenti. Riprova più tardi."
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
                message = "Esito dell’acquisto non riconosciuto."
            }
        } catch {
            message = "Acquisto non completato. Verifica la connessione e riprova."
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = isPremium ? "Acquisti ripristinati." : "Non risultano acquisti da ripristinare."
        } catch {
            message = "Ripristino non riuscito. Riprova più tardi."
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if (transaction.productID == Self.monthlyID || transaction.productID == Self.annualID),
               transaction.revocationDate == nil {
                active = true
            }
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

    deinit { updatesTask?.cancel() }
}
