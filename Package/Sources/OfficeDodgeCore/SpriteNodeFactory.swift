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
            nodeName: "player",
            usesContrastPlate: false
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
            nodeName: "obstacle",
            usesContrastPlate: false
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
        if let texture = textureFromSFSymbol(
            named: "heart.fill",
            tint: UIColor(red: 1, green: 0.36, blue: 0.36, alpha: 1),
            pointSize: size + 2
        ) {
            let node = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            node.name = "hud_lives_icon"
            return node
        }
        let fallback = SKLabelNode(text: "♥︎")
        fallback.name = "hud_lives_icon"
        fallback.fontColor = UIColor(red: 1, green: 0.36, blue: 0.36, alpha: 1)
        fallback.fontSize = size
        fallback.verticalAlignmentMode = .center
        fallback.horizontalAlignmentMode = .center
        return fallback
    }

    static func makeHUDPauseNode(size: CGFloat = 20) -> SKNode {
        if let texture = textureFromSFSymbol(
            named: "pause.circle.fill",
            tint: UIColor(red: 1, green: 0.92, blue: 0.35, alpha: 1),
            pointSize: size + 2
        ) {
            let node = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            node.name = "hud_pause_icon"
            return node
        }
        let fallback = SKLabelNode(text: "II")
        fallback.name = "hud_pause_icon"
        fallback.fontColor = UIColor(red: 1, green: 0.92, blue: 0.35, alpha: 1)
        fallback.fontSize = size * 0.9
        fallback.verticalAlignmentMode = .center
        fallback.horizontalAlignmentMode = .center
        return fallback
    }

    static func makeCoffeePowerUpNode(size: CGFloat = 30) -> SKNode {
        makeSpriteNode(
            assetName: GameAssetName.powerUpCoffee,
            fallbackSymbolName: "cup.and.saucer.fill",
            fallbackEmoji: "☕",
            tint: .systemBrown,
            size: size,
            nodeName: "powerup_coffee",
            usesContrastPlate: false
        )
    }

    private static func makeSpriteNode(
        assetName: String,
        fallbackSymbolName: String,
        fallbackEmoji: String,
        tint: SKColor,
        size: CGFloat,
        nodeName: String,
        usesContrastPlate: Bool
    ) -> SKNode {
        if let texture = textureFromAsset(named: assetName) {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            return makeWrappedNode(
                sprite: sprite,
                size: size,
                nodeName: nodeName,
                usesContrastPlate: usesContrastPlate
            )
        }

        if let texture = textureFromSFSymbol(named: fallbackSymbolName, tint: tint, pointSize: size) {
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
            return makeWrappedNode(
                sprite: sprite,
                size: size,
                nodeName: nodeName,
                usesContrastPlate: usesContrastPlate
            )
        }

        let label = SKLabelNode(text: fallbackEmoji)
        label.fontSize = size
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return makeWrappedNode(
            sprite: label,
            size: size,
            nodeName: nodeName,
            usesContrastPlate: usesContrastPlate
        )
    }

    private static func makeWrappedNode(
        sprite: SKNode,
        size: CGFloat,
        nodeName: String,
        usesContrastPlate: Bool
    ) -> SKNode {
        guard usesContrastPlate else {
            sprite.name = nodeName
            return sprite
        }

        let container = SKNode()
        container.name = nodeName

        let plate = SKShapeNode(circleOfRadius: size * 0.46)
        plate.fillColor = UIColor.black.withAlphaComponent(0.14)
        plate.strokeColor = .clear
        plate.lineWidth = 0
        plate.zPosition = -1
        container.addChild(plate)

        if let spriteNode = sprite as? SKSpriteNode {
            spriteNode.size = CGSize(width: size * 0.98, height: size * 0.98)
            spriteNode.zPosition = 1
        } else if let labelNode = sprite as? SKLabelNode {
            labelNode.zPosition = 1
        }
        container.addChild(sprite)
        return container
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
