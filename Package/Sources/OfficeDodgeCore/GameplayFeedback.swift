import Foundation
import SpriteKit

#if canImport(UIKit)
import UIKit
#endif

enum GameSoundCue: String, CaseIterable {
    case hit = "sfx_hit.wav"
    case gameOver = "sfx_game_over.wav"
    case buttonTap = "sfx_button_tap.wav"
}

final class GameplayFeedback {
    #if canImport(UIKit)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    #endif

    func prepare() {
        #if canImport(UIKit)
        selectionGenerator.prepare()
        impactGenerator.prepare()
        notificationGenerator.prepare()
        #endif
    }

    func buttonTap(in scene: SKScene) {
        playSound(.buttonTap, in: scene)
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
        #endif
    }

    func playerHit(in scene: SKScene, didGameOver: Bool) {
        playSound(didGameOver ? .gameOver : .hit, in: scene)
        #if canImport(UIKit)
        if didGameOver {
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
        } else {
            impactGenerator.impactOccurred(intensity: 0.9)
            impactGenerator.prepare()
        }
        #endif
    }

    func powerUpCollected() {
        #if canImport(UIKit)
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
        #endif
    }

    private func playSound(_ cue: GameSoundCue, in scene: SKScene) {
        let fileName = cue.rawValue
        let components = fileName.split(separator: ".", maxSplits: 1).map(String.init)
        guard components.count == 2 else { return }
        let resource = components[0]
        let ext = components[1]
        guard Bundle.main.path(forResource: resource, ofType: ext) != nil else { return }
        scene.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
    }
}
