import Foundation

public struct SpawnPlanRequest: Sendable {
    public let seed: UInt64
    public let duration: TimeInterval
    public let dt: TimeInterval
    public let sceneWidth: Double
    public let initialSpawnDelay: TimeInterval
    public let startingScore: Int

    public init(
        seed: UInt64,
        duration: TimeInterval,
        dt: TimeInterval,
        sceneWidth: Double = 390,
        initialSpawnDelay: TimeInterval = 0.5,
        startingScore: Int = 0
    ) {
        self.seed = seed
        self.duration = max(0, duration)
        self.dt = max(0, dt)
        self.sceneWidth = max(1, sceneWidth)
        self.initialSpawnDelay = max(0, initialSpawnDelay)
        self.startingScore = max(0, startingScore)
    }
}

public enum SpawnPlanGenerator {
    public static func generate(
        request: SpawnPlanRequest,
        difficultyModel: DifficultyModel = DifficultyModel()
    ) -> [SpawnEvent] {
        guard request.duration > 0, request.dt > 0 else { return [] }

        var rng = SeededRNG(seed: request.seed)
        var spawner = Spawner(initialDelay: request.initialSpawnDelay)

        var elapsedTime: TimeInterval = 0
        var score = request.startingScore
        var events: [SpawnEvent] = []

        while elapsedTime < request.duration {
            let step = min(request.dt, request.duration - elapsedTime)
            elapsedTime += step
            score += Int(step * 10)

            let tickEvents = spawner.update(
                dt: step,
                elapsedTime: elapsedTime,
                score: score,
                sceneWidth: request.sceneWidth,
                difficultyModel: difficultyModel,
                rng: &rng
            )
            events.append(contentsOf: tickEvents)
        }

        return events
    }
}
