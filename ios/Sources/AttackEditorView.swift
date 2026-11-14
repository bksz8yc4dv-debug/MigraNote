import SwiftUI
import SwiftData

struct AttackEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var attack: Attack
    @AppStorage("customFieldNames") private var customFieldNamesRaw = ""
    @StateObject private var premium = PremiumManager.shared
    @State private var selectedFactors: Set<String> = []

    private var customFieldNames: [String] {
        customFieldNamesRaw.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Data e ora") {
                    DatePicker("Inizio dell’attacco", selection: $attack.timestamp)
                }
                Section {
                    ForEach(AttackOptions.factors, id: \.self) { factor in
                        Button {
                            if factor == "Nessuna causa evidente" {
                                if selectedFactors.contains(factor) { selectedFactors.remove(factor) }
                                else { selectedFactors = [factor] }
                            } else {
                                selectedFactors.remove("Nessuna causa evidente")
                                if selectedFactors.contains(factor) { selectedFactors.remove(factor) }
                                else { selectedFactors.insert(factor) }
                            }
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
                    Text("Facoltativo. Puoi completare questi dettagli anche in seguito.")
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
                if premium.isPremium && !customFieldNames.isEmpty {
                    Section("Campi personalizzati · Premium") {
                        ForEach(customFieldNames, id: \.self) { name in
                            TextField(name, text: customBinding(for: name))
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

    private func customBinding(for name: String) -> Binding<String> {
        Binding(
            get: {
                let data = Data(attack.customFieldValuesJSON.utf8)
                let values = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
                return values[name] ?? ""
            },
            set: { value in
                let data = Data(attack.customFieldValuesJSON.utf8)
                var values = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
                values[name] = value
                if let encoded = try? JSONEncoder().encode(values),
                   let string = String(data: encoded, encoding: .utf8) {
                    attack.customFieldValuesJSON = string
                }
            }
        )
    }
}
