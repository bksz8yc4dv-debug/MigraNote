import SwiftUI
import UIKit
import UniformTypeIdentifiers
import SwiftData

struct ExportView: View {
    let attacks: [Attack]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var shareURL: URL?
    @State private var errorMessage: String?
    @State private var statusMessage: String?
    @State private var showingImporter = false
    @AppStorage("customFieldNames") private var customFieldNamesRaw = ""
    @StateObject private var premium = PremiumManager.shared

    private var customFieldNames: [String] {
        customFieldNamesRaw.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("\(attacks.count) registrazioni disponibili.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: createCSV) {
                    Label("Crea e condividi CSV", systemImage: "tablecells")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
                Button(action: createPDF) {
                    Label("Crea report PDF (Premium)", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!premium.isPremium)
                Button(action: createBackup) {
                    Label("Crea backup JSON (Premium)", systemImage: "externaldrive")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
                .disabled(!premium.isPremium)
                Button {
                    showingImporter = true
                } label: {
                    Label("Ripristina da backup (Premium)", systemImage: "arrow.counterclockwise.icloud")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
                .disabled(!premium.isPremium)
                if !premium.isPremium {
                    Text("PDF e backup/ripristino sono funzioni Premium. Il CSV resta gratuito.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if let statusMessage {
                    Text(statusMessage).font(.footnote).foregroundStyle(.green)
                }
                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Esportazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Chiudi") { dismiss() } } }
            .sheet(isPresented: Binding(
                get: { shareURL != nil },
                set: { if !$0 { shareURL = nil } }
            )) {
                if let shareURL { ShareSheet(items: [shareURL]) }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false,
                onCompletion: restoreBackup
            )
        }
    }

    private func createCSV() {
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("migranote.csv")
            try csv.write(to: url, atomically: true, encoding: .utf8)
            shareURL = url
        } catch {
            errorMessage = "Impossibile creare il CSV: \(error.localizedDescription)"
        }
    }

    private func createPDF() {
        guard premium.isPremium else { return }
        do {
            shareURL = try PDFExportService.createReport(attacks: attacks, customFieldNames: customFieldNames)
        } catch {
            errorMessage = "Impossibile creare il PDF: \(error.localizedDescription)"
        }
    }

    private func createBackup() {
        guard premium.isPremium else { return }
        do {
            shareURL = try BackupService.createFile(attacks: attacks)
        } catch {
            errorMessage = "Impossibile creare il backup: \(error.localizedDescription)"
        }
    }

    private func restoreBackup(_ result: Result<[URL], Error>) {
        guard premium.isPremium else { return }
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let payload = try BackupService.decode(Data(contentsOf: url))
            var knownIDs = Set(attacks.map(\.id))
            var restored = 0
            for record in payload.attacks where knownIDs.insert(record.id).inserted {
                modelContext.insert(record.makeAttack())
                restored += 1
            }
            try modelContext.save()
            statusMessage = "Ripristinate \(restored) registrazioni. I dati già presenti non sono stati duplicati."
            errorMessage = nil
        } catch {
            errorMessage = "Ripristino non riuscito: \(error.localizedDescription)"
            statusMessage = nil
        }
    }

    private var csv: String {
        let headers = ["Data", "Ora", "Intensità", "Durata", "Fattori", "Note"] + customFieldNames
        var rows = [headers.map(quote).joined(separator: ",")]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "yyyy-MM-dd,HH:mm"
        for attack in attacks {
            let fields = formatter.string(from: attack.timestamp).components(separatedBy: ",") + [
                attack.intensity.map(String.init) ?? "",
                attack.duration ?? "",
                attack.factors.joined(separator: "; "),
                attack.notes
            ]
            let data = Data(attack.customFieldValuesJSON.utf8)
            let customValues = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
            rows.append((fields + customFieldNames.map { customValues[$0] ?? "" }).map(quote).joined(separator: ","))
        }
        return "\u{FEFF}" + rows.joined(separator: "\n")
    }

    private func quote(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
