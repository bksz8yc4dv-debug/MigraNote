import SwiftUI
import SwiftData

struct HistoryView: View {
    let attacks: [Attack]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                if attacks.isEmpty {
                    ContentUnavailableView("Nessun attacco", systemImage: "list.bullet", description: Text("Le registrazioni compariranno qui."))
                }
                ForEach(attacks) { attack in
                    NavigationLink {
                        AttackEditorView(attack: attack)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(attack.timestamp.formatted(date: .long, time: .shortened)).font(.headline)
                            Text(attack.intensity.map { "Intensità \($0)/10" } ?? "Dettagli da completare")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    offsets.map { attacks[$0] }.forEach(context.delete)
                    try? context.save()
                }
            }
            .navigationTitle("Storico")
            .toolbar { EditButton() }
        }
    }
}
