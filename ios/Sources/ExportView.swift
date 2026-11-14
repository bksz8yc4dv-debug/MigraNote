import SwiftUI
import UIKit

struct ExportView: View {
    let attacks: [Attack]
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?
    @State private var errorMessage: String?
    @StateObject private var premium = PremiumManager.shared

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
                if !premium.isPremium {
                    Text("Il report PDF è una funzione Premium. Puoi comunque esportare gratuitamente il diario in CSV.")
                        .font(.footnote).foregroundStyle(.secondary)
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
            shareURL = try PDFExportService.createReport(attacks: attacks)
        } catch {
            errorMessage = "Impossibile creare il PDF: \(error.localizedDescription)"
        }
    }

    private var csv: String {
        var rows = ["Data,Ora,Intensità,Durata,Fattori,Note"]
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
            rows.append(fields.map(quote).joined(separator: ","))
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
