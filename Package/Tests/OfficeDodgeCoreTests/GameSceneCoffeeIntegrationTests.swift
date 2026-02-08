@testable import OfficeDodgeCore
import SpriteKit
import XCTest

@MainActor
final class GameSceneCoffeeIntegrationTests: XCTestCase {
    func testCoffeePowerUpSpawnsFallsOffscreenWhenMissedAndRespawns() {
        let scene = makeScene(seed: 0xDEADBEEF)
        var currentTime: TimeInterval = 0

        XCTAssertTrue(
            advanceUntil(
                scene,
                currentTime: &currentTime,
                timeout: 20,
                removingObstacles: true
            ) {
                scene.childNode(withName: "powerup_coffee") != nil
            }
        )

        guard let coffeeNode = scene.childNode(withName: "powerup_coffee"),
              let playerNode = scene.childNode(withName: "player") else {
            return XCTFail("Expected player and coffee nodes to exist.")
        }

        let targetX = min(max(18, playerNode.position.x - 130), scene.size.width - 18)
        coffeeNode.position.x = targetX

        XCTAssertTrue(
            advanceUntil(
                scene,
                currentTime: &currentTime,
                timeout: 10,
                removingObstacles: true
            ) {
                scene.childNode(withName: "powerup_coffee") == nil
            }
        )

        XCTAssertTrue(
            advanceUntil(
                scene,
                currentTime: &currentTime,
                timeout: 20,
                removingObstacles: true
            ) {
                scene.childNode(withName: "powerup_coffee") != nil
            }
        )
    }

    func testCoffeeBoostPreventsGameOverUntilBoostExpires() {
        let scene = makeScene(seed: 0xBADC0FFE)
        var currentTime: TimeInterval = 0
        var didGameOver = false
        scene.onGameOver = { _ in
            didGameOver = true
        }

        guard let playerNode = scene.childNode(withName: "player") else {
            return XCTFail("Expected player node to exist.")
        }

        let coffeeNode = SpriteNodeFactory.makeCoffeePowerUpNode(size: 34)
        coffeeNode.position = playerNode.position
        scene.addChild(coffeeNode)

        advance(scene, currentTime: &currentTime, by: 0.2, removingObstacles: true)
        XCTAssertTrue(isCoffeeBoostVisible(in: scene))

        let obstacleDuringBoost = ObstacleFactory.makeNode(type: .email, size: 46)
        obstacleDuringBoost.position = playerNode.position
        scene.addChild(obstacleDuringBoost)

        advance(scene, currentTime: &currentTime, by: 0.05, removingObstacles: false)
        XCTAssertFalse(didGameOver)

        advance(scene, currentTime: &currentTime, by: 4.5, removingObstacles: true)
        XCTAssertFalse(isCoffeeBoostVisible(in: scene))

        let obstacleAfterExpiry = ObstacleFactory.makeNode(type: .bug, size: 46)
        obstacleAfterExpiry.position = playerNode.position
        scene.addChild(obstacleAfterExpiry)

        advance(scene, currentTime: &currentTime, by: 0.05, removingObstacles: false)
        XCTAssertTrue(didGameOver)
    }

    private func makeScene(seed: UInt64) -> GameScene {
        let size = CGSize(width: 320, height: 640)
        let scene = GameScene(size: size, seed: seed, lives: 1)
        let view = SKView(frame: CGRect(origin: .zero, size: size))
        scene.didMove(to: view)
        return scene
    }

    private func advance(
        _ scene: GameScene,
        currentTime: inout TimeInterval,
        by duration: TimeInterval,
        removingObstacles: Bool,
        step: TimeInterval = 1.0 / 60.0
    ) {
        let endTime = currentTime + duration
        while currentTime < endTime {
            currentTime += step
            scene.update(currentTime)
            if removingObstacles {
                scene.enumerateChildNodes(withName: "obstacle") { node, _ in
                    node.removeFromParent()
                }
            }
        }
    }

    private func advanceUntil(
        _ scene: GameScene,
        currentTime: inout TimeInterval,
        timeout: TimeInterval,
        removingObstacles: Bool,
        predicate: () -> Bool
    ) -> Bool {
        if predicate() {
            return true
        }

        let endTime = currentTime + timeout
        while currentTime < endTime {
            advance(scene, currentTime: &currentTime, by: 1.0 / 60.0, removingObstacles: removingObstacles)
            if predicate() {
                return true
            }
        }
        return predicate()
    }

    private func isCoffeeBoostVisible(in scene: SKScene) -> Bool {
        scene.children
            .compactMap { ($0 as? SKLabelNode)?.text }
            .contains { $0.contains("Coffee x1.6") }
    }
}
