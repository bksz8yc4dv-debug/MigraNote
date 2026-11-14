import Foundation
import SwiftData

@Model
final class Attack: Identifiable {
    var id: UUID
    var timestamp: Date
    var factors: [String]
    var intensity: Int?
    var duration: String?
    var notes: String
    var customFieldValuesJSON: String

    init(id: UUID = UUID(), timestamp: Date = .now, factors: [String] = [], intensity: Int? = nil, duration: String? = nil, notes: String = "", customFieldValuesJSON: String = "{}") {
        self.id = id
        self.timestamp = timestamp
        self.factors = factors
        self.intensity = intensity
        self.duration = duration
        self.notes = notes
        self.customFieldValuesJSON = customFieldValuesJSON
    }
}

enum AttackOptions {
    static let factors = [
        "Sforzo fisico", "Stress", "Poco sonno", "Stanchezza",
        "Pasto saltato", "Nessuna causa evidente", "Altro"
    ]
    static let durations = [
        "Ancora in corso", "Meno di un’ora", "1–4 ore",
        "4–12 ore", "12–24 ore", "Più di 24 ore"
    ]
}
