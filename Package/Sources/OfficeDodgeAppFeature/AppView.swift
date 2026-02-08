import OfficeDodgeCore
import SpriteKit
import SwiftUI

public struct AppView: View {
    @State private var screen: Screen = .menu
    @State private var lastScore = 0
    @State private var highScores: [Int]
    private let highScoreStore: HighScoreStoring

    public init(highScoreStore: HighScoreStoring = HighScoreStore()) {
        self.highScoreStore = highScoreStore
        _highScores = State(initialValue: highScoreStore.loadScores())
    }

    public var body: some View {
        switch screen {
        case .menu:
            VStack(spacing: 16) {
                Text("Office Dodge")
                    .font(.largeTitle.bold())
                Text("Dodge incoming office chaos.")
                    .foregroundStyle(.secondary)
                Button("Start") {
                    screen = .playing
                }
                .buttonStyle(.borderedProminent)
                .minimumTapTarget()
                Button("High Scores") {
                    screen = .highScores
                }
                .buttonStyle(.bordered)
                .minimumTapTarget()
                Button("Settings") {
                    screen = .settings
                }
                .buttonStyle(.bordered)
                .minimumTapTarget()
            }
            .padding()
        case .playing:
            GameSceneContainer { score in
                lastScore = score
                highScores = highScoreStore.record(score: score)
                screen = .gameOver
            }
            .ignoresSafeArea()
        case .gameOver:
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.title.bold())
                Text("Score: \(lastScore)")
                if let best = highScores.first {
                    Text("Best: \(best)")
                        .foregroundStyle(.secondary)
                }
                Button("Restart") {
                    screen = .playing
                }
                .buttonStyle(.borderedProminent)
                .minimumTapTarget()
                Button("Main Menu") {
                    screen = .menu
                }
                .buttonStyle(.bordered)
                .minimumTapTarget()
            }
            .padding()
        case .highScores:
            VStack(spacing: 16) {
                Text("High Scores")
                    .font(.title.bold())
                if highScores.isEmpty {
                    Text("No scores yet")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(highScores.enumerated()), id: \.offset) { index, score in
                            HStack {
                                Text("#\(index + 1)")
                                    .fontWeight(.semibold)
                                    .frame(width: 36, alignment: .leading)
                                Text("\(score)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(maxWidth: 220)
                }
                Button("Reset Scores") {
                    highScoreStore.clear()
                    highScores = []
                }
                .buttonStyle(.bordered)
                .minimumTapTarget()
                Button("Back") {
                    screen = .menu
                }
                .buttonStyle(.borderedProminent)
                .minimumTapTarget()
            }
            .padding()
        case .settings:
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.title.bold())
                Text("Coming soon")
                    .foregroundStyle(.secondary)
                Button("Back") {
                    screen = .menu
                }
                .buttonStyle(.borderedProminent)
                .minimumTapTarget()
            }
            .padding()
        }
    }
}

private enum Screen {
    case menu
    case playing
    case gameOver
    case highScores
    case settings
}

private struct GameSceneContainer: View {
    let onGameOver: (Int) -> Void

    var body: some View {
        SpriteView(scene: makeScene())
    }

    private func makeScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 390, height: 844), seed: 0xDEADBEEFCAFEBABE)
        scene.scaleMode = .resizeFill
        scene.onGameOver = onGameOver
        return scene
    }
}

private extension View {
    func minimumTapTarget() -> some View {
        self
            .controlSize(.large)
            .frame(minHeight: 44)
    }
}
