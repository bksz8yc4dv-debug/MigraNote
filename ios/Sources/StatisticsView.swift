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
    private var monthlyCounts: [(month: String, count: Int)] {
        let grouped = Dictionary(grouping: attacks) {
            Calendar.current.dateInterval(of: .month, for: $0.timestamp)?.start ?? $0.timestamp
        }
        return grouped.keys.sorted().suffix(6).map { date in
            (month: date.formatted(.dateTime.month(.abbreviated).year()), count: grouped[date]?.count ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Riepilogo") {
                    LabeledContent("Attacchi totali", value: "\(attacks.count)")
                    LabeledContent("Giorni con attacchi", value: "\(attackDays)")
                    LabeledContent("Intensità media", value: averageIntensity.map { String(format: "%.1f / 10", $0) } ?? "—")
                }
                Section("Andamento mensile") {
                    if monthlyCounts.isEmpty {
                        Text("Le statistiche appariranno dopo le prime registrazioni.").foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(monthlyCounts.enumerated()), id: \.offset) { _, item in
                            HStack {
                                Text(item.month)
                                Spacer()
                                Text("\(item.count)").fontWeight(.semibold).monospacedDigit()
                            }
                        }
                    }
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
