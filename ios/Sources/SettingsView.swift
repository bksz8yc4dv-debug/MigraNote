import SwiftUI

struct SettingsView: View {
    let attacks: [Attack]
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var showingPremium = false
    @State private var showingExport = false
    @StateObject private var premium = PremiumManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Dati e privacy") {
                    Text("Il diario è archiviato sul dispositivo. Non serve creare un account e MigraNote non mostra pubblicità.")
                    Toggle("Proteggi con Face ID", isOn: $biometricLockEnabled)
                    Button("Esporta diario (CSV / PDF)") { showingExport = true }
                }
                Section("MigraNote Premium") {
                    HStack {
                        Text("Stato")
                        Spacer()
                        Text(premium.isPremium ? "Attivo" : "Versione gratuita")
                            .foregroundStyle(premium.isPremium ? .green : .secondary)
                    }
                    Button("Gestisci Premium") { showingPremium = true }
                }
                Section("Informazioni") {
                    LabeledContent("Versione", value: "Anteprima iOS")
                    Text("MigraNote è un diario personale e non sostituisce il parere di un professionista sanitario.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Impostazioni")
            .sheet(isPresented: $showingPremium) { PremiumView() }
            .sheet(isPresented: $showingExport) { ExportView(attacks: attacks) }
        }
    }
}

struct PremiumView: View {
    @StateObject private var premium = PremiumManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Funzioni Premium") {
                    Label("Statistiche avanzate", systemImage: "chart.xyaxis.line")
                    Label("Report PDF", systemImage: "doc.richtext")
                    Label("Campi personalizzati", systemImage: "slider.horizontal.3")
                    Label("Backup e sincronizzazione", systemImage: "icloud")
                }
                Section("Abbonamenti") {
                    if premium.products.isEmpty {
                        Text("Gli abbonamenti non sono ancora disponibili. I prodotti devono essere configurati e approvati in App Store Connect.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    ForEach(premium.products, id: \.id) { product in
                        Button {
                            Task { await premium.purchase(product) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.id == PremiumManager.monthlyID ? "Mensile" : "Annuale")
                                        .foregroundStyle(.primary)
                                    Text(product.displayPrice).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Abbonati").fontWeight(.semibold)
                            }
                        }
                        .disabled(premium.isPremium)
                    }
                    Button("Ripristina acquisti") { Task { await premium.restore() } }
                    if premium.isPremium {
                        Label("Premium attivo", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                    }
                    if let message = premium.message {
                        Text(message).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Section {
                    Text("L’abbonamento si rinnova automaticamente salvo disdetta nelle impostazioni dell’account Apple.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("MigraNote Premium")
            .navigationBarTitleDisplayMode(.inline)
            .task { await premium.loadProducts(); await premium.refreshEntitlements() }
        }
    }
}
