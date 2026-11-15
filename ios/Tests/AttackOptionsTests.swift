import XCTest
@testable import MigraNote

final class AttackOptionsTests: XCTestCase {
    func testExpectedFactorsAreAvailable() {
        XCTAssertEqual(AttackOptions.factors.count, 7)
        XCTAssertTrue(AttackOptions.factors.contains("Stress"))
        XCTAssertTrue(AttackOptions.factors.contains("Poco sonno"))
    }

    func testExpectedDurationChoicesAreAvailable() {
        XCTAssertEqual(AttackOptions.durations.count, 6)
        XCTAssertEqual(AttackOptions.durations.first, "Ancora in corso")
    }

    func testAttackDefaultsToOptionalDetails() {
        let attack = Attack()
        XCTAssertNil(attack.intensity)
        XCTAssertNil(attack.duration)
        XCTAssertTrue(attack.factors.isEmpty)
        XCTAssertEqual(attack.notes, "")
        XCTAssertEqual(attack.customFieldValuesJSON, "{}")
    }

    func testNewAttackCapturesCreationTime() {
        let before = Date()
        let attack = Attack()
        let after = Date()

        XCTAssertGreaterThanOrEqual(attack.timestamp, before)
        XCTAssertLessThanOrEqual(attack.timestamp, after)
    }

    func testBackupRoundTripPreservesAttackData() throws {
        let original = Attack(
            timestamp: Date(timeIntervalSince1970: 1_700_000_000),
            factors: ["Stress", "Poco sonno"],
            intensity: 7,
            duration: "4–12 ore",
            notes: "Test note",
            customFieldValuesJSON: #"{\"Trigger\":\"Luce\"}"#
        )
        let url = try BackupService.createFile(attacks: [original])
        defer { try? FileManager.default.removeItem(at: url) }
        let restored = try BackupService.decode(Data(contentsOf: url))

        XCTAssertEqual(restored.schemaVersion, 1)
        XCTAssertEqual(restored.attacks.count, 1)
        XCTAssertEqual(restored.attacks[0].id, original.id)
        XCTAssertEqual(restored.attacks[0].timestamp, original.timestamp)
        XCTAssertEqual(restored.attacks[0].factors, original.factors)
        XCTAssertEqual(restored.attacks[0].intensity, original.intensity)
        XCTAssertEqual(restored.attacks[0].duration, original.duration)
        XCTAssertEqual(restored.attacks[0].notes, original.notes)
        XCTAssertEqual(restored.attacks[0].customFieldValuesJSON, original.customFieldValuesJSON)
    }

    func testUnsupportedBackupVersionIsRejected() throws {
        let payload = BackupPayload(schemaVersion: 99, exportedAt: .now, attacks: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        XCTAssertThrowsError(try BackupService.decode(data))
    }
}
