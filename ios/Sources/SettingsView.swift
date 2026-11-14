import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var premium: PremiumStore

    var body: some View {
        List {
            Section("MigraNote Premium") {
                HStack {
                    Label(premium.isPremium ? "Premium attivo" : "Versione gratuita", systemImage: "crown")
                    Spacer()
                    if premium.isPremium { Text("Attivo").foregroundStyle(.green) }
                }
                Text("Premium è pensato per statistiche avanzate, report dettagliati e funzioni aggiuntive.")
                    .font(.subheadline).foregroundStyle(.secondary)
                if premium.products.isEmpty {
                    Text("Gli abbonamenti non sono ancora disponibili: devono essere creati e approvati in App Store Connect.")
                        .font(.footnote).foregroundStyle(.secondary)
                } else {
                    ForEach(premium.products, id: \.id) { product in
                        Button {
                            Task { await premium.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                        }
                        .disabled(premium.isPremium)
                    }
                }
                Button("Ripristina acquisti") { Task { await premium.restore() } }
                if let message = premium.message {
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                }
            }

            Section("Privacy") {
                Label("I dati degli attacchi sono salvati localmente su questo iPhone.", systemImage: "iphone")
                Label("Questa versione non invia i dati a server esterni.", systemImage: "lock.shield")
                Label("Puoi esportare report PDF/CSV e creare un backup completo JSON dalla scheda Esporta.", systemImage: "square.and.arrow.up")
                Label("La sincronizzazione automatica iCloud non è ancora attiva.", systemImage: "icloud.slash")
            }

            Section("Informazioni") {
                LabeledContent("App", value: "MigraNote")
                LabeledContent("Versione", value: "Anteprima sviluppo")
            }
        }
        .navigationTitle("Impostazioni")
    }
}
