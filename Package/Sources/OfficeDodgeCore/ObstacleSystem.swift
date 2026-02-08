import CoreGraphics
import Foundation
import SpriteKit

enum ObstacleSystem {
    static func makeSpawnedNode(
        for event: SpawnEvent,
        sceneHeight: CGFloat,
        obstacleSize: CGFloat,
        obstacleTypeUserDataKey: String
    ) -> SKNode {
        let node = ObstacleFactory.makeNode(type: event.type, size: obstacleSize)
        if node.userData == nil {
            node.userData = NSMutableDictionary()
        }
        node.userData?[obstacleTypeUserDataKey] = event.type.rawValue
        node.position = CGPoint(x: CGFloat(event.x), y: sceneHeight + 30)
        return node
    }

    static func advanceObstacles(
        in scene: SKScene,
        dt: TimeInterval,
        speedMultiplier: Double,
        baseFallSpeed: CGFloat,
        playerX: CGFloat,
        sceneWidth: CGFloat,
        obstacleSize: CGFloat,
        managerHomingSpeed: CGFloat,
        hudProtectedHeight: CGFloat,
        obstacleTypeUserDataKey: String
    ) {
        _ = baseFallSpeed
        let speed = CGFloat(190 * speedMultiplier)
        let hudBoundaryY = scene.size.height - hudProtectedHeight
        scene.enumerateChildNodes(withName: "obstacle") { node, _ in
            if obstacleType(for: node, obstacleTypeUserDataKey: obstacleTypeUserDataKey) == .manager {
                let maxStep = managerHomingSpeed * CGFloat(dt)
                let deltaX = playerX - node.position.x
                let clampedStep = max(min(deltaX, maxStep), -maxStep)
                node.position.x += clampedStep
                let half = obstacleSize / 2
                node.position.x = min(max(node.position.x, half), sceneWidth - half)
            }
            node.position.y -= speed * CGFloat(dt)
            node.alpha = node.position.y > hudBoundaryY ? 0 : 1
            if node.position.y < -60 {
                node.removeFromParent()
            }
        }
    }

    static func meetingSlowdownMultiplier(
        in scene: SKScene,
        playerPosition: CGPoint,
        obstacleTypeUserDataKey: String,
        radiusX: CGFloat,
        radiusY: CGFloat,
        slowdownMultiplier: CGFloat
    ) -> CGFloat {
        var multiplier: CGFloat = 1
        scene.enumerateChildNodes(withName: "obstacle") { node, _ in
            guard obstacleType(for: node, obstacleTypeUserDataKey: obstacleTypeUserDataKey) == .meeting else { return }

            let dx = abs(node.position.x - playerPosition.x)
            let dy = abs(node.position.y - playerPosition.y)
            guard dx <= radiusX, dy <= radiusY else { return }

            multiplier = min(multiplier, slowdownMultiplier)
        }
        return multiplier
    }

    static func removeFirstCollidingObstacle(
        in scene: SKScene,
        playerFrame: CGRect,
        obstacleInset: CGFloat,
        playerInset: CGFloat
    ) -> Bool {
        var hit = false
        scene.enumerateChildNodes(withName: "obstacle") { node, stop in
            if CollisionSystem.intersects(
                node.frame,
                playerFrame,
                insetA: obstacleInset,
                insetB: playerInset
            ) {
                hit = true
                node.removeFromParent()
                stop.pointee = true
            }
        }
        return hit
    }

    static func obstacleType(for node: SKNode, obstacleTypeUserDataKey: String) -> ObstacleType? {
        guard let raw = node.userData?[obstacleTypeUserDataKey] as? String else { return nil }
        return ObstacleType(rawValue: raw)
    }
}
