import Foundation
import SwiftUI

struct MigraineAttack: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var startedAt: Date = Date()
    var intensity: Int? = nil
    var durationMinutes: Int? = nil
    var factors: [String] = []
    var notes: String = ""
}

@MainActor
final class AttackStore: ObservableObject {
    @Published private(set) var attacks: [MigraineAttack] = []
    private let storageKey = "migranote.attacks.v1"

    init() { load() }

    func addAttack() -> MigraineAttack {
        let attack = MigraineAttack()
        attacks.insert(attack, at: 0)
        save()
        return attack
    }

    func update(_ attack: MigraineAttack) {
        guard let index = attacks.firstIndex(where: { $0.id == attack.id }) else { return }
        attacks[index] = attack
        attacks.sort { $0.startedAt > $1.startedAt }
        save()
    }

    func delete(_ attack: MigraineAttack) {
        attacks.removeAll { $0.id == attack.id }
        save()
    }

    func replaceAll(with importedAttacks: [MigraineAttack]) {
        attacks = importedAttacks.sorted { $0.startedAt > $1.startedAt }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MigraineAttack].self, from: data) else { return }
        attacks = decoded.sorted { $0.startedAt > $1.startedAt }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(attacks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
