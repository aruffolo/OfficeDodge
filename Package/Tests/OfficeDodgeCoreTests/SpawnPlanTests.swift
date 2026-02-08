import OfficeDodgeCore
import XCTest

final class SpawnPlanTests: XCTestCase {
    func testGenerateProducesStableFirstTwentyEvents() {
        let request = SpawnPlanRequest(
            seed: 0xDEADBEEFCAFEBABE,
            duration: 20,
            dt: 0.1,
            sceneWidth: 390
        )

        let events = SpawnPlanGenerator.generate(request: request)
        XCTAssertEqual(events.count, 23)

        let expected: [(TimeInterval, ObstacleType, Double)] = [
            (0.6, .email, 111.389359641310),
            (1.7, .jira, 327.220921011385),
            (2.9, .email, 279.301725290649),
            (4.0, .meeting, 184.973815142838),
            (5.1, .manager, 387.326028181683),
            (6.1, .jira, 163.282726674223),
            (7.1, .email, 374.715068609894),
            (8.1, .email, 1.420084727242),
            (9.1, .meeting, 121.302180630984),
            (10.0, .jira, 296.559624211177),
            (10.9, .bug, 83.650084705766),
            (11.8, .bug, 63.979056705908),
            (12.6, .meeting, 241.448356896249),
            (13.5, .bug, 341.603323112919),
            (14.2, .manager, 386.734280818098),
            (15.0, .jira, 284.515708221922),
            (15.8, .jira, 265.037173200395),
            (16.5, .bug, 274.292994844111),
            (17.2, .email, 377.163015089252),
            (17.9, .bug, 189.681528661018),
        ]

        for (index, expectedEvent) in expected.enumerated() {
            let event = events[index]
            XCTAssertEqual(event.time, expectedEvent.0, accuracy: 0.000_000_1)
            XCTAssertEqual(event.type, expectedEvent.1)
            XCTAssertEqual(event.x, expectedEvent.2, accuracy: 0.000_000_1)
        }
    }

    func testGenerateIsDeterministicForSameSeed() {
        let request = SpawnPlanRequest(seed: 12345, duration: 8, dt: 0.1)
        let first = SpawnPlanGenerator.generate(request: request)
        let second = SpawnPlanGenerator.generate(request: request)

        XCTAssertEqual(first, second)
    }

    func testGenerateChangesWhenSeedChanges() {
        let first = SpawnPlanGenerator.generate(request: SpawnPlanRequest(seed: 1, duration: 8, dt: 0.1))
        let second = SpawnPlanGenerator.generate(request: SpawnPlanRequest(seed: 2, duration: 8, dt: 0.1))

        XCTAssertFalse(first.isEmpty)
        XCTAssertFalse(second.isEmpty)
        XCTAssertNotEqual(first, second)
    }
}
