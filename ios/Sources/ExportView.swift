import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ExportView: View {
    let attacks: [Attack]
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("\(attacks.count) registrazioni disponibili per l’esportazione.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    do {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent("migranote.csv")
                        try csv.write(to: url, atomically: true, encoding: .utf8)
                        shareURL = url
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                } label: {
                    Label("Crea e condividi CSV", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                Spacer()
            }
            .padding()
            .navigationTitle("Esportazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Chiudi") { dismiss() } } }
            .sheet(item: Binding(get: { shareURL.map(ShareFile.init) }, set: { shareURL = $0?.url })) { file in
                ShareSheet(items: [file.url])
            }
        }
    }

    private var csv: String {
        var rows = ["Data,Ora,Intensità,Durata,Fattori,Note"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "yyyy-MM-dd,HH:mm"
        for attack in attacks {
            let date = formatter.string(from: attack.timestamp)
            let fields = date.components(separatedBy: ",") + [
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
        let safe = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"" + safe + "\""
    }
}

private struct ShareFile: Identifiable {
    let id = UUID()
    let url: URL
    init(_ url: URL) { self.url = url }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
