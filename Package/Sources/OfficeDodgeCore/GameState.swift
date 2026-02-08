import Foundation

public enum GamePhase: Equatable {
    case menu
    case running
    case paused
    case gameOver(finalScore: Int)
}

public struct GameState: Equatable {
    public var score: Int
    public var lives: Int
    public var phase: GamePhase

    public init(score: Int = 0, lives: Int = 1, phase: GamePhase = .menu) {
        self.score = score
        self.lives = lives
        self.phase = phase
    }

    public mutating func startRun() {
        score = 0
        lives = max(lives, 1)
        phase = .running
    }

    public mutating func addScore(points: Int) {
        guard case .running = phase else { return }
        score += max(0, points)
    }

    public mutating func pause() {
        guard case .running = phase else { return }
        phase = .paused
    }

    public mutating func resume() {
        guard case .paused = phase else { return }
        phase = .running
    }

    public mutating func registerCollision() {
        guard case .running = phase else { return }
        lives -= 1
        if lives <= 0 {
            phase = .gameOver(finalScore: score)
        }
    }
}
