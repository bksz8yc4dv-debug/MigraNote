import Foundation

struct AttackBackupRecord: Codable {
    let id: UUID
    let timestamp: Date
    let factors: [String]
    let intensity: Int?
    let duration: String?
    let notes: String
    let customFieldValuesJSON: String

    init(attack: Attack) {
        id = attack.id
        timestamp = attack.timestamp
        factors = attack.factors
        intensity = attack.intensity
        duration = attack.duration
        notes = attack.notes
        customFieldValuesJSON = attack.customFieldValuesJSON
    }

    func makeAttack() -> Attack {
        Attack(
            id: id,
            timestamp: timestamp,
            factors: factors,
            intensity: intensity,
            duration: duration,
            notes: notes,
            customFieldValuesJSON: customFieldValuesJSON
        )
    }
}

struct BackupPayload: Codable {
    let schemaVersion: Int
    let exportedAt: Date
    let attacks: [AttackBackupRecord]
}

enum BackupService {
    static func createFile(attacks: [Attack]) throws -> URL {
        let payload = BackupPayload(
            schemaVersion: 1,
            exportedAt: .now,
            attacks: attacks.map(AttackBackupRecord.init(attack:))
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(payload)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("MigraNote-Backup.json")
        try data.write(to: url, options: .atomic)
        return url
    }

    static func decode(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(BackupPayload.self, from: data)
        guard payload.schemaVersion == 1 else {
            throw BackupError.unsupportedVersion
        }
        return payload
    }
}

enum BackupError: LocalizedError {
    case unsupportedVersion

    var errorDescription: String? {
        "Versione del backup non supportata."
    }
}
