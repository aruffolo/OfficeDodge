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
            usesContrastPlate: false,
            cropInsets: AssetCropInsets(top: 0.10, left: 0.18, bottom: 0.06, right: 0.15)
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
            usesContrastPlate: false,
            cropInsets: cropInsets(for: assetName)
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
        let heart = SKLabelNode(text: "♥︎")
        heart.name = "hud_lives_icon"
        heart.fontName = "Menlo-Bold"
        heart.fontColor = UIColor(red: 1, green: 0.26, blue: 0.26, alpha: 1)
        heart.fontSize = size * 1.02
        heart.verticalAlignmentMode = .center
        heart.horizontalAlignmentMode = .center
        return heart
    }

    static func makeHUDPauseNode(size: CGFloat = 20) -> SKNode {
        let icon = SKLabelNode(text: "II")
        icon.name = "hud_pause_icon"
        icon.fontName = "Menlo-Bold"
        icon.fontColor = UIColor(red: 1, green: 0.92, blue: 0.35, alpha: 1)
        icon.fontSize = size * 0.95
        icon.verticalAlignmentMode = .center
        icon.horizontalAlignmentMode = .center
        return icon
    }

    static func makeCoffeePowerUpNode(size: CGFloat = 30) -> SKNode {
        return makeSpriteNode(
            assetName: GameAssetName.powerUpCoffee,
            fallbackSymbolName: "cup.and.saucer.fill",
            fallbackEmoji: "☕",
            tint: .systemBrown,
            size: size,
            nodeName: "powerup_coffee",
            usesContrastPlate: false,
            cropInsets: AssetCropInsets(top: 0.05, left: 0.06, bottom: 0.10, right: 0.06)
        )
    }

    private static func makeSpriteNode(
        assetName: String,
        fallbackSymbolName: String,
        fallbackEmoji: String,
        tint: SKColor,
        size: CGFloat,
        nodeName: String,
        usesContrastPlate: Bool,
        cropInsets: AssetCropInsets?
    ) -> SKNode {
        if let texture = textureFromAsset(named: assetName) {
            let sprite = makeSpriteFromAssetTexture(texture, size: size, cropInsets: cropInsets)
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

    private static func makeSpriteFromAssetTexture(
        _ texture: SKTexture,
        size: CGFloat,
        cropInsets: AssetCropInsets?
    ) -> SKSpriteNode {
        let sprite: SKSpriteNode
        if let cropInsets {
            let rect = cropInsets.clampedUnitRect
            let croppedTexture = SKTexture(rect: rect, in: texture)
            sprite = SKSpriteNode(texture: croppedTexture, size: CGSize(width: size, height: size))
        } else {
            sprite = SKSpriteNode(texture: texture, size: CGSize(width: size, height: size))
        }
        sprite.centerRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        return sprite
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

    private static func cropInsets(for assetName: String) -> AssetCropInsets? {
        switch assetName {
        case GameAssetName.obstacleEmail:
            return AssetCropInsets(top: 0.14, left: 0.05, bottom: 0.16, right: 0.02)
        case GameAssetName.obstacleMeeting:
            return AssetCropInsets(top: 0.01, left: 0.08, bottom: 0.03, right: 0.03)
        case GameAssetName.obstacleBug:
            return AssetCropInsets(top: 0.17, left: 0.16, bottom: 0.18, right: 0.16)
        case GameAssetName.obstacleManager:
            return AssetCropInsets(top: 0.08, left: 0.13, bottom: 0.05, right: 0.10)
        case GameAssetName.obstacleJira:
            return AssetCropInsets(top: 0.01, left: 0.00, bottom: 0.03, right: 0.00)
        default:
            return nil
        }
    }
}

private struct AssetCropInsets {
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat

    var clampedUnitRect: CGRect {
        let safeLeft = min(max(left, 0), 0.49)
        let safeRight = min(max(right, 0), 0.49)
        let safeTop = min(max(top, 0), 0.49)
        let safeBottom = min(max(bottom, 0), 0.49)
        let width = max(0.02, 1 - safeLeft - safeRight)
        let height = max(0.02, 1 - safeTop - safeBottom)
        let x = min(max(safeLeft, 0), 1 - width)
        let y = min(max(safeBottom, 0), 1 - height)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
