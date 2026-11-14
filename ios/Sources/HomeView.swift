import SwiftUI

struct HomeView: View {
    let attacks: [Attack]
    let onRecord: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MigraNote").font(.largeTitle.bold())
                        Text("Il tuo diario dell’emicrania").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: onRecord) {
                        VStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 38))
                            Text("REGISTRA ATTACCO").font(.title2.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .foregroundStyle(.white)
                        .background(Color.purple, in: RoundedRectangle(cornerRadius: 26))
                    }
                    .accessibilityHint("Salva immediatamente data e ora di inizio dell’attacco")

                    HStack(spacing: 12) {
                        summaryCard(title: "Attacchi totali", value: "\(attacks.count)")
                        summaryCard(title: "Ultimo attacco", value: attacks.first?.timestamp.formatted(date: .abbreviated, time: .omitted) ?? "Nessuno")
                    }

                    if let last = attacks.first {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ultima registrazione").font(.headline)
                            Text(last.timestamp.formatted(date: .complete, time: .shortened))
                            Text(last.intensity.map { "Intensità: \($0)/10" } ?? "Dettagli ancora da completare")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private func summaryCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(value).font(.title3.bold())
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
    }
}
