import SwiftUI
import SwiftData

struct AttackEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var attack: Attack
    @State private var selectedFactors: Set<String> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Data e ora") {
                    DatePicker("Inizio dell’attacco", selection: $attack.timestamp)
                }
                Section {
                    ForEach(AttackOptions.factors, id: \.self) { factor in
                        Button {
                            if selectedFactors.contains(factor) { selectedFactors.remove(factor) }
                            else { selectedFactors.insert(factor) }
                            attack.factors = Array(selectedFactors)
                        } label: {
                            HStack {
                                Text(factor).foregroundStyle(.primary)
                                Spacer()
                                if selectedFactors.contains(factor) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Cosa è successo prima?")
                } footer: {
                    Text("Facoltativo. Puoi selezionare più fattori o completare questi dettagli in seguito.")
                }
                Section("Intensità del dolore") {
                    Toggle("Indica l’intensità", isOn: Binding(
                        get: { attack.intensity != nil },
                        set: { attack.intensity = $0 ? 5 : nil }
                    ))
                    if attack.intensity != nil {
                        Slider(value: Binding(
                            get: { Double(attack.intensity ?? 5) },
                            set: { attack.intensity = Int($0) }
                        ), in: 1...10, step: 1)
                        Text("\(attack.intensity ?? 5) / 10").font(.headline).foregroundStyle(.purple)
                    }
                }
                Section("Durata") {
                    Picker("Durata", selection: $attack.duration) {
                        Text("Non indicata").tag(String?.none)
                        ForEach(AttackOptions.durations, id: \.self) { item in
                            Text(item).tag(Optional(item))
                        }
                    }
                }
                Section("Note") {
                    TextField("Scrivi quello che vuoi…", text: $attack.notes, axis: .vertical)
                        .lineLimit(3...7)
                }
            }
            .navigationTitle("Dettagli attacco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine") {
                        try? context.save()
                        dismiss()
                    }
                }
            }
            .onAppear { selectedFactors = Set(attack.factors) }
        }
    }
}
