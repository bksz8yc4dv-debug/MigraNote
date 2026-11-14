import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: AttackStore
    @State private var month = Calendar.current.firstDayOfMonth(for: .now)
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["L", "M", "M", "G", "V", "S", "D"]

    private var days: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let weekday = calendar.component(.weekday, from: month)
        let mondayOffset = (weekday + 5) % 7
        return Array(repeating: nil, count: mondayOffset) + range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: month)
        }.map(Optional.some)
    }

    private var selectedAttacks: [MigraineAttack] {
        store.attacks.filter { Calendar.current.isDate($0.startedAt, inSameDayAs: selectedDate) }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(month.formatted(.dateTime.month(.wide).year())).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index]).font(.caption.bold()).foregroundStyle(.secondary)
                }
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        let count = store.attacks.filter { Calendar.current.isDate($0.startedAt, inSameDayAs: date) }.count
                        Button { selectedDate = date } label: {
                            VStack(spacing: 4) {
                                Text(date.formatted(.dateTime.day()))
                                    .font(.body.weight(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .bold : .regular))
                                Circle().fill(count > 0 ? Color.accentColor : .clear).frame(width: 5, height: 5)
                            }
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.accentColor.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 42)
                    }
                }
            }
            .padding(.horizontal)

            Divider()
            HStack {
                Text(selectedDate.formatted(date: .complete, time: .omitted)).font(.headline)
                Spacer()
                Text("\(selectedAttacks.count) attacchi").foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if selectedAttacks.isEmpty {
                ContentUnavailableView("Nessun attacco", systemImage: "calendar", description: Text("Non risultano attacchi registrati in questa giornata."))
                Spacer()
            } else {
                List(selectedAttacks) { attack in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(attack.startedAt.formatted(date: .omitted, time: .shortened)).font(.headline)
                        Text("Intensità: \(attack.intensity.map(String.init) ?? "—")/10")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.top)
        .navigationTitle("Calendario")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func changeMonth(_ amount: Int) {
        if let next = Calendar.current.date(byAdding: .month, value: amount, to: month) {
            month = next
            selectedDate = next
        }
    }
}

private extension Calendar {
    func firstDayOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
