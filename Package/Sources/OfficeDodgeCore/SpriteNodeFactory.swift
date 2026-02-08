import CoreGraphics
import SpriteKit

#if canImport(UIKit)
import UIKit
#endif

public enum GameAssetName {
    public static let playerAvatar = "player_avatar"
    public static let obstacleEmail = "obstacle_email"
    public static let obstacleMeeting = "obstacle_meeting"
    public static let obstacleBug = "obstacle_bug"
    public static let obstacleManager = "obstacle_manager"
    public static let obstacleJira = "obstacle_jira"
    public static let backgroundOffice = "background_office"
    public static let hudLives = "hud_lives"
    public static let hudPause = "hud_pause"
    public static let powerUpCoffee = "powerup_coffee"
}

enum SpriteNodeFactory {
    static func makePlayerNode(size: CGFloat = 44) -> SKNode {
        makeSpriteNode(
            assetName: GameAssetName.playerAvatar,
            fallbackSymbolName: "person.fill",
            fallbackEmoji: "🙂",
            tint: .systemYellow,
            size: size,
            nodeName: "player"
        )
    }

    static func makeObstacleNode(
        assetName: String,
        fallbackSymbolName: String,
        fallbackEmoji: String,
        size: CGFloat = 42
    ) -> SKNode {
        makeSpriteNode(
            assetName: assetName,
            fallbackSymbolName: fallbackSymbolName,
            fallbackEmoji: fallbackEmoji,
            tint: .white,
            size: size,
            nodeName: "obstacle"
        )
    }

    static func makeBackgroundNode(sceneSize: CGSize) -> SKSpriteNode? {
        guard let texture = textureFromAsset(named: GameAssetName.backgroundOffice) else { return nil }
        let node = SKSpriteNode(texture: texture, size: sceneSize)
        node.name = "background"
        node.zPosition = -100
        return node
    }

    static func makeHUDLivesNode(size: CGFloat = 20) -> SKNode {
        makeSpriteNode(
            assetName: GameAssetName.hudLives,
            fallbackSymbolName: "heart.fill",
            fallbackEmoji: "❤️",
            tint: .white,
            size: size,
            nodeName: "hud_lives_icon"
        )
    }

    static func makeHUDPauseNode(size: CGFloat = 20) -> SKNode {
        makeSpriteNode(
            assetName: GameAssetName.hudPause,
            fallbackSymbolName: "pause.circle.fill",
            fallbackEmoji: "⏸",
            tint: .white,
            size: size,
            nodeName: "hud_pause_icon"
        )
    }

    static func makeCoffeePowerUpNode(size: CGFloat = 30) -> SKNode {
        makeSpriteNode(
            assetName: GameAssetName.powerUpCoffee,
            fallbackSymbolName: "cup.and.saucer.fill",
            fallbackEmoji: "☕",
            tint: .systemBrown,
            size: size,
            nodeName: "powerup_coffee"
        )
    }

    private static func makeSpriteNode(
        assetName: String,
        fallbackSymbolName: String,
        fallbackEmoji: String,
        tint: SKColor,
        size: CGFloat,
        nodeName: String
    ) -> SKNode {
        if let texture = textureFromAsset(named: assetName) {
            let node = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            node.name = nodeName
            return node
        }

        if let texture = textureFromSFSymbol(named: fallbackSymbolName, tint: tint, pointSize: size) {
            let node = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            node.name = nodeName
            return node
        }

        let node = SKLabelNode(text: fallbackEmoji)
        node.fontSize = size
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.name = nodeName
        return node
    }

    private static func textureFromAsset(named assetName: String) -> SKTexture? {
        #if canImport(UIKit)
        guard let image = UIImage(named: assetName) else { return nil }
        return SKTexture(image: image)
        #else
        return nil
        #endif
    }

    private static func textureFromSFSymbol(named symbolName: String, tint: SKColor, pointSize: CGFloat) -> SKTexture? {
        #if canImport(UIKit)
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold)
        guard let image = UIImage(systemName: symbolName, withConfiguration: config)?
            .withTintColor(tint, renderingMode: .alwaysOriginal) else {
            return nil
        }
        return SKTexture(image: image)
        #else
        return nil
        #endif
    }
}
