import SwiftUI

struct CalendarView: View {
    let attacks: [Attack]
    @State private var month = Calendar.current.startOfMonth(for: .now)
    @State private var selectedDate: Date?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private var days: [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: month) ?? 1..<2
        let weekday = calendar.component(.weekday, from: month)
        let offset = (weekday + 5) % 7
        return Array(repeating: nil, count: offset) + range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
    }
    private func hasAttack(_ date: Date) -> Bool {
        attacks.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Button { month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month } label: { Image(systemName: "chevron.left") }
                    Spacer()
                    Text(month.formatted(.dateTime.month(.wide).year())).font(.title2.bold())
                    Spacer()
                    Button { month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month } label: { Image(systemName: "chevron.right") }
                }
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(["L", "M", "M", "G", "V", "S", "D"].enumerated()), id: \.offset) { _, day in
                        Text(day).font(.caption.bold()).frame(maxWidth: .infinity)
                    }
                    ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                        if let date {
                            Button {
                                selectedDate = date
                            } label: {
                                Text(date.formatted(.dateTime.day()))
                                    .frame(maxWidth: .infinity, minHeight: 42)
                                    .background(hasAttack(date) ? Color.purple : Color.clear, in: Circle())
                                    .foregroundStyle(hasAttack(date) ? .white : .primary)
                            }
                        } else {
                            Color.clear.frame(height: 42)
                        }
                    }
                }
                if let selectedDate {
                    let selected = attacks.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
                    List(selected) { attack in
                        VStack(alignment: .leading) {
                            Text(attack.timestamp.formatted(date: .omitted, time: .shortened))
                            Text(attack.intensity.map { "Intensità \($0)/10" } ?? "Dettagli da completare")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text("I giorni colorati indicano almeno un attacco.").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Calendario")
        }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        dateInterval(of: .month, for: date)?.start ?? date
    }
}
