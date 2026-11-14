import SwiftUI
import UniformTypeIdentifiers

private let factorsList = ["Sforzo fisico", "Stress", "Poco sonno", "Stanchezza", "Pasto saltato", "Nessuna causa evidente", "Altro"]

struct MainTabView: View {
    @EnvironmentObject private var store: AttackStore
    @State private var editingAttack: MigraineAttack?
    @State private var showEditor = false

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("MigraNote").font(.largeTitle.bold())
                        Text("Il tuo diario, senza complicazioni.")
                            .foregroundStyle(.secondary)
                        Button {
                            editingAttack = store.addAttack()
                            showEditor = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill").font(.system(size: 34))
                                Text("Registra un attacco").font(.title2.bold())
                                Text("Salva subito data e ora").font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .foregroundStyle(.white)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 24))
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Riepilogo").font(.headline)
                            HStack {
                                SummaryTile(title: "Attacchi", value: "\(store.attacks.count)")
                                SummaryTile(title: "Questo mese", value: "\(store.attacks.filter { Calendar.current.isDate($0.startedAt, equalTo: .now, toGranularity: .month) }.count)")
                            }
                        }
                        if let latest = store.attacks.first {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ultimo attacco").font(.headline)
                                AttackRow(attack: latest)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingAttack = latest; showEditor = true }
                            }
                        }
                    }
                    .padding()
                }
                .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                List {
                    ForEach(store.attacks) { attack in
                        Button { editingAttack = attack; showEditor = true } label: {
                            AttackRow(attack: attack)
                        }
                        .tint(.primary)
                    }
                    .onDelete { offsets in
                        for index in offsets { store.delete(store.attacks[index]) }
                    }
                }
                .overlay {
                    if store.attacks.isEmpty {
                        ContentUnavailableView("Nessun attacco", systemImage: "calendar", description: Text("Gli attacchi registrati compariranno qui."))
                    }
                }
                .navigationTitle("Storico")
            }
            .tabItem { Label("Storico", systemImage: "list.bullet") }

            NavigationStack {
                CalendarView()
            }
            .tabItem { Label("Calendario", systemImage: "calendar") }

            NavigationStack {
                StatsView()
                    .navigationTitle("Statistiche")
            }
            .tabItem { Label("Statistiche", systemImage: "chart.bar") }

            NavigationStack {
                ExportView()
                    .navigationTitle("Esporta")
            }
            .tabItem { Label("Esporta", systemImage: "square.and.arrow.up") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Altro", systemImage: "gearshape") }
        }
        .sheet(isPresented: $showEditor, onDismiss: { editingAttack = nil }) {
            if let attack = editingAttack {
                AttackEditor(attack: attack) { updated in store.update(updated) }
            }
        }
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value).font(.largeTitle.bold())
            Text(title).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct AttackRow: View {
    let attack: MigraineAttack
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(attack.startedAt.formatted(date: .long, time: .shortened)).font(.headline)
            HStack {
                Text("Intensità: \(attack.intensity.map(String.init) ?? "—")/10")
                Text("•")
                Text(attack.durationMinutes.map { "\($0) min" } ?? "Durata non indicata")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 5)
    }
}

private struct AttackEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var attack: MigraineAttack
    let onSave: (MigraineAttack) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Quando è iniziato") {
                    DatePicker("Data e ora", selection: $attack.startedAt)
                }
                Section("Intensità") {
                    HStack {
                        Text(attack.intensity.map(String.init) ?? "Non indicata")
                        Spacer()
                        Slider(value: Binding(
                            get: { Double(attack.intensity ?? 5) },
                            set: { attack.intensity = Int($0.rounded()) }
                        ), in: 1...10, step: 1)
                    }
                    .accessibilityElement(children: .combine)
                }
                Section("Durata") {
                    Picker("Durata", selection: Binding(
                        get: { attack.durationMinutes ?? 0 },
                        set: { attack.durationMinutes = $0 == 0 ? nil : $0 }
                    )) {
                        Text("Non indicata").tag(0)
                        Text("Meno di 1 ora").tag(30)
                        Text("1–2 ore").tag(120)
                        Text("3–6 ore").tag(360)
                        Text("6–12 ore").tag(720)
                        Text("12–24 ore").tag(1440)
                        Text("Oltre 24 ore").tag(2880)
                    }
                }
                Section("Possibili fattori") {
                    ForEach(factorsList, id: \.self) { factor in
                        Toggle(factor, isOn: Binding(
                            get: { attack.factors.contains(factor) },
                            set: { enabled in
                                if enabled { attack.factors.append(factor) }
                                else { attack.factors.removeAll { $0 == factor } }
                            }
                        ))
                    }
                }
                Section("Note") {
                    TextEditor(text: $attack.notes).frame(minHeight: 100)
                }
            }
            .navigationTitle("Dettagli attacco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Chiudi") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") { onSave(attack); dismiss() }
                }
            }
        }
    }
}

private struct StatsView: View {
    @EnvironmentObject private var store: AttackStore
    var body: some View {
        List {
            Section("Totale") { LabeledContent("Attacchi registrati", value: "\(store.attacks.count)") }
            Section("Intensità media") {
                let values = store.attacks.compactMap(\.intensity)
                LabeledContent("Media", value: values.isEmpty ? "—" : String(format: "%.1f/10", Double(values.reduce(0, +)) / Double(values.count)))
            }
            Section("Fattori più indicati") {
                let counts = Dictionary(store.attacks.flatMap(\.factors).map { ($0, 1) }, uniquingKeysWith: +)
                ForEach(counts.sorted(by: { $0.value > $1.value }), id: \.key) { item in
                    LabeledContent(item.key, value: "\(item.value)")
                }
            }
        }
    }
}

private struct ExportView: View {
    @EnvironmentObject private var store: AttackStore
    @State private var pdfURL: URL?
    @State private var csvURL: URL?
    @State private var showBackupExporter = false
    @State private var showBackupImporter = false
    @State private var backupMessage: String?

    var body: some View {
        List {
            Section("Report") {
                Button("Prepara report PDF") { pdfURL = ExportService.pdf(store.attacks) }
                if let pdfURL { ShareLink(item: pdfURL) { Label("Condividi PDF", systemImage: "doc.richtext") } }
                Button("Prepara file CSV") { csvURL = ExportService.csv(store.attacks) }
                if let csvURL { ShareLink(item: csvURL) { Label("Condividi CSV", systemImage: "tablecells") } }
            }

            Section("Backup completo") {
                Text("Il backup JSON contiene tutti gli attacchi e i relativi dettagli. Salvalo in File o in un altro spazio sicuro.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button {
                    showBackupExporter = true
                } label: {
                    Label("Esporta backup JSON", systemImage: "externaldrive")
                }
                Button(role: .destructive) {
                    showBackupImporter = true
                } label: {
                    Label("Importa backup JSON", systemImage: "square.and.arrow.down")
                }
                Text("Attenzione: importare un backup sostituisce tutti gli attacchi attualmente presenti su questo iPhone.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .fileExporter(
            isPresented: $showBackupExporter,
            document: MigraNoteBackupDocument(attacks: store.attacks),
            contentType: .json,
            defaultFilename: "MigraNote-backup"
        ) { result in
            if case .failure(let error) = result {
                backupMessage = "Esportazione non riuscita: \\(error.localizedDescription)"
            }
        }
        .fileImporter(
            isPresented: $showBackupImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                let data = try Data(contentsOf: url)
                let payload = try MigraNoteBackupDocument.decode(data: data)
                store.replaceAll(with: payload.attacks)
                backupMessage = "Backup importato. Sono stati ripristinati \\(payload.attacks.count) attacchi."
            } catch {
                backupMessage = "Importazione non riuscita: \\(error.localizedDescription)"
            }
        }
        .alert("Backup", isPresented: Binding(
            get: { backupMessage != nil },
            set: { if !$0 { backupMessage = nil } }
        )) {
            Button("OK") { backupMessage = nil }
        } message: {
            Text(backupMessage ?? "")
        }
    }
}
