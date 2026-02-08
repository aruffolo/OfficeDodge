import Foundation

public struct DifficultyInput: Equatable {
    public let elapsedTime: TimeInterval
    public let score: Int

    public init(elapsedTime: TimeInterval, score: Int) {
        self.elapsedTime = max(0, elapsedTime)
        self.score = max(0, score)
    }
}

public struct DifficultyOutput: Equatable {
    public let spawnInterval: TimeInterval
    public let speedMultiplier: Double

    public init(spawnInterval: TimeInterval, speedMultiplier: Double) {
        self.spawnInterval = spawnInterval
        self.speedMultiplier = speedMultiplier
    }
}

public struct DifficultyModel {
    public init() {}

    public func output(for input: DifficultyInput) -> DifficultyOutput {
        let spawnInterval = max(0.30, 1.20 - input.elapsedTime * 0.02 - Double(input.score) * 0.001)
        let speedMultiplier = min(3.0, 1.0 + input.elapsedTime * 0.03 + Double(input.score) * 0.002)
        return DifficultyOutput(spawnInterval: spawnInterval, speedMultiplier: speedMultiplier)
    }
}
