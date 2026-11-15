import SwiftUI
import SwiftData

struct AttackEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var attack: Attack
    var isNewAttack = false
    @AppStorage("customFieldNames") private var customFieldNamesRaw = ""
    @StateObject private var premium = PremiumManager.shared
    @State private var selectedFactors: Set<String> = []
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    private var customFieldNames: [String] {
        customFieldNamesRaw.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                if isNewAttack {
                    Section {
                        Label("Attacco registrato", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Data e ora sono già state salvate. I dettagli sono facoltativi: puoi aggiungerli ora oppure tornare più tardi.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Data e ora") {
                    DatePicker(
                        "Inizio dell’attacco",
                        selection: $attack.timestamp,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section {
                    ForEach(AttackOptions.factors, id: \.self) { factor in
                        Button {
                            if factor == "Nessuna causa evidente" {
                                if selectedFactors.contains(factor) {
                                    selectedFactors.remove(factor)
                                } else {
                                    selectedFactors = [factor]
                                }
                            } else {
                                selectedFactors.remove("Nessuna causa evidente")
                                if selectedFactors.contains(factor) {
                                    selectedFactors.remove(factor)
                                } else {
                                    selectedFactors.insert(factor)
                                }
                            }
                            attack.factors = AttackOptions.factors.filter { selectedFactors.contains($0) }
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
                    Text("Cosa hai notato prima?")
                } footer: {
                    Text("Facoltativo. Sono annotazioni personali, non cause certe. Puoi completarle anche in seguito.")
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
                        Text("\(attack.intensity ?? 5) / 10")
                            .font(.headline)
                            .foregroundStyle(.purple)
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

                Section("Note facoltative") {
                    TextField(
                        selectedFactors.contains("Altro")
                            ? "Specifica Altro o aggiungi note…"
                            : "Aggiungi una nota, se vuoi…",
                        text: $attack.notes,
                        axis: .vertical
                    )
                    .lineLimit(3...7)
                }
            }
            .navigationTitle("Dettagli attacco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isNewAttack ? "Più tardi" : "Chiudi") {
                        saveAndDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveAndDismiss()
                    }
                }
            }
            .interactiveDismissDisabled()
            .alert("Salvataggio non riuscito", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveErrorMessage)
            }
            .onAppear {
                selectedFactors = Set(attack.factors)
            }
        }
    }

    private func saveAndDismiss() {
        do {
            try context.save()
            dismiss()
        } catch {
            saveErrorMessage = "Le modifiche non sono state salvate. Il modulo resta aperto: riprova. Dettaglio: \(error.localizedDescription)"
            showingSaveError = true
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
