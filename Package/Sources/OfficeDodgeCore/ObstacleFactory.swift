import CoreGraphics
import SpriteKit

public enum ObstacleType: String, CaseIterable, Equatable, Sendable {
    case email
    case meeting
    case bug
    case manager
    case jira
}

public enum ObstacleFactory {
    public static func makeNode(type: ObstacleType, size: CGFloat = 42) -> SKNode {
        let visual = visual(for: type)
        return SpriteNodeFactory.makeObstacleNode(
            assetName: visual.assetName,
            fallbackSymbolName: visual.symbolName,
            fallbackEmoji: visual.emoji,
            size: size
        )
    }

    public static func symbol(for type: ObstacleType) -> String {
        switch type {
        case .email:
            return "📧"
        case .meeting:
            return "📅"
        case .bug:
            return "🐞"
        case .manager:
            return "🧑‍💼"
        case .jira:
            return "✅"
        }
    }

    private static func visual(for type: ObstacleType) -> ObstacleVisual {
        switch type {
        case .email:
            return ObstacleVisual(assetName: GameAssetName.obstacleEmail, symbolName: "envelope.fill", emoji: "📧")
        case .meeting:
            return ObstacleVisual(assetName: GameAssetName.obstacleMeeting, symbolName: "calendar", emoji: "📅")
        case .bug:
            return ObstacleVisual(assetName: GameAssetName.obstacleBug, symbolName: "ant.fill", emoji: "🐞")
        case .manager:
            return ObstacleVisual(assetName: GameAssetName.obstacleManager, symbolName: "person.crop.rectangle.fill", emoji: "🧑‍💼")
        case .jira:
            return ObstacleVisual(assetName: GameAssetName.obstacleJira, symbolName: "checkmark.circle.fill", emoji: "✅")
        }
    }
}

private struct ObstacleVisual {
    let assetName: String
    let symbolName: String
    let emoji: String
}
