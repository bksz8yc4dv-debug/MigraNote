import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MigraNoteBackupPayload: Codable {
    let formatVersion: Int
    let exportedAt: Date
    let attacks: [MigraineAttack]

    init(attacks: [MigraineAttack]) {
        self.formatVersion = 1
        self.exportedAt = Date()
        self.attacks = attacks
    }
}

struct MigraNoteBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    let payload: MigraNoteBackupPayload

    init(attacks: [MigraineAttack]) {
        self.payload = MigraNoteBackupPayload(attacks: attacks)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoded = try JSONDecoder().decode(MigraNoteBackupPayload.self, from: data)
        guard decoded.formatVersion == 1 else {
            throw BackupError.unsupportedVersion
        }
        guard decoded.attacks.count <= 100_000 else {
            throw BackupError.invalidContent
        }
        let identifiers = decoded.attacks.map(\.id)
        guard Set(identifiers).count == identifiers.count,
              decoded.attacks.allSatisfy({ (1...10).contains($0.intensity ?? 5) && ($0.durationMinutes ?? 0) >= 0 }) else {
            throw BackupError.invalidContent
        }
        self.payload = decoded
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return FileWrapper(regularFileWithContents: data)
    }

    enum BackupError: LocalizedError {
        case unsupportedVersion
        case invalidContent

        var errorDescription: String? {
            switch self {
            case .unsupportedVersion:
                return "Questo backup è stato creato con una versione non supportata."
            case .invalidContent:
                return "Il file non contiene dati MigraNote validi."
            }
        }
    }
}
