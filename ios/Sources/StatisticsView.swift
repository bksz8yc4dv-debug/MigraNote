import SwiftUI

struct StatisticsView: View {
    let attacks: [Attack]
    private var averageIntensity: Double? {
        let values = attacks.compactMap(\.intensity)
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
    private var attackDays: Int {
        Set(attacks.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
    }
    var body: some View {
        NavigationStack {
            List {
                Section("Riepilogo") {
                    LabeledContent("Attacchi totali", value: "\(attacks.count)")
                    LabeledContent("Giorni con attacchi", value: "\(attackDays)")
                    LabeledContent("Intensità media", value: averageIntensity.map { String(format: "%.1f / 10", $0) } ?? "—")
                }
                Section("Fattori registrati") {
                    let counts = Dictionary(grouping: attacks.flatMap(\.factors), by: { $0 })
                        .mapValues(\.count)
                        .sorted { $0.value > $1.value }
                    if counts.isEmpty {
                        Text("Nessun fattore indicato.").foregroundStyle(.secondary)
                    } else {
                        ForEach(counts, id: \.key) { factor, count in
                            LabeledContent(factor, value: "\(count)")
                        }
                    }
                }
            }
            .navigationTitle("Statistiche")
        }
    }
}
