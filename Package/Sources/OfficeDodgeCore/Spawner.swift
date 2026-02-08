import Foundation

public struct SpawnEvent: Equatable {
    public let time: TimeInterval
    public let type: ObstacleType
    public let x: Double

    public init(time: TimeInterval, type: ObstacleType, x: Double) {
        self.time = time
        self.type = type
        self.x = x
    }
}

public struct Spawner {
    private var timeUntilNextSpawn: TimeInterval

    public init(initialDelay: TimeInterval = 0.5) {
        timeUntilNextSpawn = max(0, initialDelay)
    }

    public mutating func update(
        dt: TimeInterval,
        elapsedTime: TimeInterval,
        score: Int,
        sceneWidth: Double,
        difficultyModel: DifficultyModel,
        rng: inout SeededRNG
    ) -> [SpawnEvent] {
        guard dt > 0 else { return [] }

        var events: [SpawnEvent] = []
        timeUntilNextSpawn -= dt

        while timeUntilNextSpawn <= 0 {
            let roll = Int(rng.nextUInt64() % UInt64(ObstacleType.allCases.count))
            let type = ObstacleType.allCases[roll]
            let x = rng.nextUnitDouble() * max(1, sceneWidth)
            events.append(SpawnEvent(time: elapsedTime, type: type, x: x))

            let output = difficultyModel.output(for: DifficultyInput(elapsedTime: elapsedTime, score: score))
            timeUntilNextSpawn += output.spawnInterval
        }

        return events
    }
}
