import SwiftUI

struct SettingsView: View {
    let attacks: [Attack]
    @State private var showingPremium = false
    @State private var showingExport = false
    var body: some View {
        NavigationStack {
            List {
                Section("Dati e privacy") {
                    Text("Le registrazioni sono archiviate localmente sul dispositivo. Non è richiesto un account e non vengono mostrati annunci.")
                    Button("Esporta diario (CSV)") { showingExport = true }
                }
                Section("MigraNote Premium") {
                    Button("Scopri Premium") { showingPremium = true }
                    Text("Gli acquisti mensili e annuali saranno attivati solo dopo la configurazione dei prodotti Apple e la verifica con StoreKit.")
                        .font(.footnote).foregroundStyle(.secondary)
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
    var body: some View {
        NavigationStack {
            List {
                Section("Funzioni previste") {
                    Label("Statistiche avanzate", systemImage: "chart.xyaxis.line")
                    Label("Report PDF personalizzabili", systemImage: "doc.richtext")
                    Label("Esportazione CSV", systemImage: "tablecells")
                    Label("Campi personalizzati", systemImage: "slider.horizontal.3")
                    Label("Backup e sincronizzazione iCloud", systemImage: "icloud")
                }
                Section("Abbonamenti") {
                    Text("Mensile e annuale non ancora disponibili. L’attivazione richiede prodotti configurati in App Store Connect e integrazione StoreKit 2.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
