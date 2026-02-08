@testable import OfficeDodgeCore
import XCTest

final class CoffeePowerUpSystemTests: XCTestCase {
    func testResetProducesDeterministicIntervalFromSeed() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)

        XCTAssertEqual(system.timeUntilSpawn, 10, accuracy: 0.000_000_1)
        system.reset()

        XCTAssertEqual(system.timeUntilSpawn, 14.23894733058224, accuracy: 0.000_000_000_001)
    }

    func testUpdateTimeUntilSpawnOnlyTriggersWhenTimerExpires() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)
        system.reset()
        let initial = system.timeUntilSpawn

        XCTAssertFalse(system.updateTimeUntilSpawn(dt: initial - 0.01))
        XCTAssertTrue(system.updateTimeUntilSpawn(dt: 0.02))
        XCTAssertLessThanOrEqual(system.timeUntilSpawn, 0)
    }

    func testRandomSpawnXIsDeterministicAndInsidePlayableBounds() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)
        system.reset()

        let x = system.randomSpawnX(sceneWidth: 320, powerUpSize: 34)

        XCTAssertEqual(x, 296.3066414209577, accuracy: 0.000_000_001)
        XCTAssertGreaterThanOrEqual(x, 17)
        XCTAssertLessThanOrEqual(x, 303)
    }

    func testCollectedPowerUpRefreshesBoostButDoesNotStackDuration() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)

        system.handlePowerUpCollected(boostDuration: 4)
        XCTAssertTrue(system.isBoostActive)
        XCTAssertEqual(system.boostRemaining, 4, accuracy: 0.000_000_1)

        system.updateBoost(dt: 1.5)
        system.handlePowerUpCollected(boostDuration: 4)
        XCTAssertEqual(system.boostRemaining, 4, accuracy: 0.000_000_1)

        system.updateBoost(dt: 5)
        XCTAssertFalse(system.isBoostActive)
    }

    func testRepeatedCollectionsNeverIncreaseTimerBeyondConfiguredDuration() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)

        for _ in 0..<25 {
            system.handlePowerUpCollected(boostDuration: 4)
            XCTAssertEqual(system.boostRemaining, 4, accuracy: 0.000_000_1)
            system.updateBoost(dt: 0.1)
        }

        XCTAssertLessThanOrEqual(system.boostRemaining, 4)
    }

    func testRemovedPowerUpReschedulesOnlyWhenSpawnWindowExpired() {
        var system = CoffeePowerUpSystem(seed: 123, spawnIntervalMin: 10, spawnIntervalMax: 16)
        system.reset()
        let pendingInterval = system.timeUntilSpawn

        system.handlePowerUpRemovedWithoutCollection()
        XCTAssertEqual(system.timeUntilSpawn, pendingInterval, accuracy: 0.000_000_1)

        _ = system.updateTimeUntilSpawn(dt: 999)
        XCTAssertLessThanOrEqual(system.timeUntilSpawn, 0)

        system.handlePowerUpRemovedWithoutCollection()
        XCTAssertGreaterThanOrEqual(system.timeUntilSpawn, 10)
        XCTAssertLessThanOrEqual(system.timeUntilSpawn, 16)
    }
}
