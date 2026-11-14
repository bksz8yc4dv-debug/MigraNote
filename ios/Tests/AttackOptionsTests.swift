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
    }
}
