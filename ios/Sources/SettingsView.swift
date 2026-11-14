import SwiftUI

struct SettingsView: View {
    let attacks: [Attack]
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("customFieldNames") private var customFieldNamesRaw = ""
    @State private var newCustomField = ""
    @State private var showingPremium = false
    @State private var showingExport = false
    @StateObject private var premium = PremiumManager.shared

    private var customFieldNames: [String] {
        customFieldNamesRaw.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

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
                if premium.isPremium {
                    Section("Campi personalizzati · Premium") {
                        ForEach(customFieldNames, id: \.self) { name in
                            HStack {
                                Text(name)
                                Spacer()
                                Button(role: .destructive) {
                                    customFieldNamesRaw = customFieldNames.filter { $0 != name }.joined(separator: "\n")
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                            }
                        }
                        HStack {
                            TextField("Nuovo campo", text: $newCustomField)
                            Button("Aggiungi") {
                                let value = newCustomField.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !value.isEmpty && !customFieldNames.contains(value) {
                                    customFieldNamesRaw = (customFieldNames + [value]).joined(separator: "\n")
                                    newCustomField = ""
                                }
                            }
                            .disabled(newCustomField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
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
                    Label("Backup e ripristino manuale", systemImage: "externaldrive")
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
                    Text("La sincronizzazione automatica iCloud non è ancora disponibile; il backup manuale è disponibile nella sezione Esportazione.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("MigraNote Premium")
            .navigationBarTitleDisplayMode(.inline)
            .task { await premium.loadProducts(); await premium.refreshEntitlements() }
        }
    }
}
