import Foundation
import OfficeDodgeCore
import XCTest

final class HighScoreStoreTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var store: HighScoreStore!

    override func setUp() {
        super.setUp()
        suiteName = "HighScoreStoreTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        store = HighScoreStore(
            userDefaults: userDefaults,
            key: "test.high_scores",
            maxEntries: 3
        )
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        store = nil
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testRecordSortsScoresDescending() {
        _ = store.record(score: 24)
        _ = store.record(score: 80)
        _ = store.record(score: 41)

        XCTAssertEqual(store.loadScores(), [80, 41, 24])
    }

    func testRecordTrimsToConfiguredMaxEntries() {
        _ = store.record(score: 10)
        _ = store.record(score: 20)
        _ = store.record(score: 30)
        _ = store.record(score: 40)

        XCTAssertEqual(store.loadScores(), [40, 30, 20])
    }

    func testRecordIgnoresNonPositiveScores() {
        _ = store.record(score: -5)
        _ = store.record(score: 0)
        _ = store.record(score: 12)

        XCTAssertEqual(store.loadScores(), [12])
    }

    func testLoadNormalizesPersistedValues() {
        userDefaults.set([3, 11, 0, -2, 7], forKey: "test.high_scores")

        XCTAssertEqual(store.loadScores(), [11, 7, 3])
    }

    func testClearRemovesPersistedScores() {
        _ = store.record(score: 50)

        store.clear()

        XCTAssertTrue(store.loadScores().isEmpty)
    }
}
