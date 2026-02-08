import OfficeDodgeCore
import XCTest

final class DifficultyModelTests: XCTestCase {
    private let model = DifficultyModel()

    func testBaselineValuesAtStart() {
        let output = model.output(for: DifficultyInput(elapsedTime: 0, score: 0))
        XCTAssertEqual(output.spawnInterval, 1.2, accuracy: 0.000_1)
        XCTAssertEqual(output.speedMultiplier, 1.0, accuracy: 0.000_1)
    }

    func testExpectedValuesForRegularRun() {
        let output = model.output(for: DifficultyInput(elapsedTime: 10, score: 50))
        XCTAssertEqual(output.spawnInterval, 0.95, accuracy: 0.000_1)
        XCTAssertEqual(output.speedMultiplier, 1.4, accuracy: 0.000_1)
    }

    func testSpawnIntervalClampsToMinimum() {
        let output = model.output(for: DifficultyInput(elapsedTime: 100, score: 5000))
        XCTAssertEqual(output.spawnInterval, 0.3, accuracy: 0.000_1)
    }

    func testSpeedMultiplierClampsToMaximum() {
        let output = model.output(for: DifficultyInput(elapsedTime: 100, score: 5000))
        XCTAssertEqual(output.speedMultiplier, 3.0, accuracy: 0.000_1)
    }
}
