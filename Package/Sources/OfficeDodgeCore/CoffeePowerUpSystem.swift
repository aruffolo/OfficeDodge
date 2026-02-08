import CoreGraphics
import Foundation

struct CoffeePowerUpSystem {
    private let spawnIntervalMin: TimeInterval
    private let spawnIntervalMax: TimeInterval
    private var rng: SeededRNG

    private(set) var boostRemaining: TimeInterval = 0
    private(set) var timeUntilSpawn: TimeInterval

    init(seed: UInt64, spawnIntervalMin: TimeInterval, spawnIntervalMax: TimeInterval) {
        self.spawnIntervalMin = min(spawnIntervalMin, spawnIntervalMax)
        self.spawnIntervalMax = max(spawnIntervalMin, spawnIntervalMax)
        rng = SeededRNG(seed: seed)
        timeUntilSpawn = self.spawnIntervalMin
    }

    var isBoostActive: Bool {
        boostRemaining > 0
    }

    mutating func reset() {
        boostRemaining = 0
        timeUntilSpawn = nextSpawnInterval()
    }

    mutating func updateBoost(dt: TimeInterval) {
        guard dt > 0 else { return }
        boostRemaining = max(0, boostRemaining - dt)
    }

    mutating func updateTimeUntilSpawn(dt: TimeInterval) -> Bool {
        guard dt > 0 else { return false }
        timeUntilSpawn -= dt
        return timeUntilSpawn <= 0
    }

    mutating func randomSpawnX(sceneWidth: CGFloat, powerUpSize: CGFloat) -> CGFloat {
        let half = powerUpSize / 2
        let range = max(1, sceneWidth - (half * 2))
        return half + (CGFloat(rng.nextUnitDouble()) * range)
    }

    mutating func scheduleNextSpawn() {
        timeUntilSpawn = nextSpawnInterval()
    }

    mutating func handlePowerUpCollected(boostDuration: TimeInterval) {
        boostRemaining = max(0, boostDuration)
        if timeUntilSpawn <= 0 {
            scheduleNextSpawn()
        }
    }

    mutating func handlePowerUpRemovedWithoutCollection() {
        if timeUntilSpawn <= 0 {
            scheduleNextSpawn()
        }
    }

    private mutating func nextSpawnInterval() -> TimeInterval {
        let delta = max(0, spawnIntervalMax - spawnIntervalMin)
        return spawnIntervalMin + (rng.nextUnitDouble() * delta)
    }
}
