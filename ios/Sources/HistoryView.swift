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
                        AttackDetailView(attack: attack)
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

struct AttackDetailView: View {
    @Bindable var attack: Attack

    var body: some View {
        Form {
            DatePicker("Data e ora", selection: $attack.timestamp)
            Section("Fattori") {
                ForEach(AttackOptions.factors, id: \.self) { factor in
                    Toggle(factor, isOn: Binding(
                        get: { attack.factors.contains(factor) },
                        set: { enabled in
                            if enabled && !attack.factors.contains(factor) { attack.factors.append(factor) }
                            if !enabled { attack.factors.removeAll { $0 == factor } }
                        }
                    ))
                }
            }
            Section("Intensità") {
                Stepper(attack.intensity.map { "\($0)/10" } ?? "Non indicata",
                        value: Binding(get: { attack.intensity ?? 5 }, set: { attack.intensity = $0 }),
                        in: 1...10)
            }
            Section("Durata") {
                Picker("Durata", selection: $attack.duration) {
                    Text("Non indicata").tag(String?.none)
                    ForEach(AttackOptions.durations, id: \.self) { Text($0).tag(Optional($0)) }
                }
            }
            Section("Note") { TextField("Note", text: $attack.notes, axis: .vertical) }
        }
        .navigationTitle("Modifica attacco")
    }
}
