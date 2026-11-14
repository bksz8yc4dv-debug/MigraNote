import SwiftUI
import SwiftData

struct AttackEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var timestamp = Date()
    @State private var factors: Set<String> = []
    @State private var intensity = 5.0
    @State private var hasIntensity = false
    @State private var duration: String?
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Data e ora") {
                    DatePicker("Inizio dell’attacco", selection: $timestamp)
                }
                Section {
                    ForEach(AttackOptions.factors, id: \.self) { factor in
                        Button {
                            if factors.contains(factor) { factors.remove(factor) }
                            else { factors.insert(factor) }
                        } label: {
                            HStack {
                                Text(factor).foregroundStyle(.primary)
                                Spacer()
                                if factors.contains(factor) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Cosa è successo prima?")
                } footer: {
                    Text("Puoi selezionare più fattori oppure non indicarne nessuno.")
                }
                Section("Intensità del dolore") {
                    Toggle("Indica l’intensità", isOn: $hasIntensity)
                    if hasIntensity {
                        Slider(value: $intensity, in: 1...10, step: 1)
                        Text("\(Int(intensity)) / 10").font(.headline).foregroundStyle(.purple)
                    }
                }
                Section("Durata") {
                    Picker("Durata", selection: $duration) {
                        Text("Non indicata").tag(String?.none)
                        ForEach(AttackOptions.durations, id: \.self) { item in
                            Text(item).tag(Optional(item))
                        }
                    }
                }
                Section("Note") {
                    TextField("Scrivi quello che vuoi…", text: $notes, axis: .vertical)
                        .lineLimit(3...7)
                }
            }
            .navigationTitle("Nuovo attacco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let attack = Attack(timestamp: timestamp,
                                            factors: Array(factors),
                                            intensity: hasIntensity ? Int(intensity) : nil,
                                            duration: duration,
                                            notes: notes)
                        context.insert(attack)
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
