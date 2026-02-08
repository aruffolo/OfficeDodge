import SpriteKit

public final class GameScene: SKScene {
    public var onGameOver: ((Int) -> Void)?

    private let inputController = InputController()
    private let difficultyModel = DifficultyModel()
    private let feedback = GameplayFeedback()
    private var rng: SeededRNG
    private var coffeeSystem: CoffeePowerUpSystem
    private var spawner = Spawner()
    private var state: GameState

    private var player: SKNode = SKNode()
    private var backgroundNode: SKSpriteNode?
    private var scoreLabel = SKLabelNode(text: "Score: 0")
    private var livesLabel = SKLabelNode(text: "Lives: 1")
    private var pauseButtonLabel = SKLabelNode(text: "Pause")
    private var pauseStateLabel = SKLabelNode(text: "Paused")
    private var coffeeStatusLabel = SKLabelNode(text: "")
    private var livesIconNode: SKNode?
    private var pauseIconNode: SKNode?
    private let leftHUDPlate = SKShapeNode()
    private let rightHUDPlate = SKShapeNode()
    private var sceneSafeAreaInsets: UIEdgeInsets = .zero
    private var playerTargetX: CGFloat = 0

    private var lastUpdateTime: TimeInterval?
    private var elapsedTime: TimeInterval = 0

    public init(size: CGSize, seed: UInt64, lives: Int = 1) {
        rng = SeededRNG(seed: seed)
        coffeeSystem = CoffeePowerUpSystem(
            seed: seed ^ GameplayTuning.coffeePowerUpSeedSalt,
            spawnIntervalMin: GameplayTuning.coffeeSpawnIntervalMin,
            spawnIntervalMax: GameplayTuning.coffeeSpawnIntervalMax
        )
        state = GameState(lives: max(lives, 1))
        super.init(size: size)
    }

    public required init?(coder aDecoder: NSCoder) {
        rng = SeededRNG(seed: 0)
        coffeeSystem = CoffeePowerUpSystem(
            seed: GameplayTuning.coffeePowerUpSeedSalt,
            spawnIntervalMin: GameplayTuning.coffeeSpawnIntervalMin,
            spawnIntervalMax: GameplayTuning.coffeeSpawnIntervalMax
        )
        state = GameState(lives: 1)
        super.init(coder: aDecoder)
    }

    public override func didMove(to view: SKView) {
        configureBackground()
        configurePlayer()
        updateSafeAreaInsets()
        configureHUD()
        feedback.prepare()
        resetCoffeePowerUpState()
        state.startRun()
        updateHUD()
    }

    public override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        backgroundNode?.size = size
        backgroundNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        updateSafeAreaInsets()
        layoutHUD()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if pauseButtonLabel.contains(location) {
            feedback.buttonTap(in: self)
            togglePauseState()
            return
        }
        if pauseIconNode?.contains(location) == true {
            feedback.buttonTap(in: self)
            togglePauseState()
            return
        }

        guard case .running = state.phase else { return }
        playerTargetX = inputController.clampedPlayerX(
            location.x,
            sceneWidth: size.width,
            playerHalfWidth: GameplayTuning.playerSize / 2,
            edgePadding: GameplayTuning.playerEdgePadding
        )
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .running = state.phase else { return }
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        playerTargetX = inputController.clampedPlayerX(
            x,
            sceneWidth: size.width,
            playerHalfWidth: GameplayTuning.playerSize / 2,
            edgePadding: GameplayTuning.playerEdgePadding
        )
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .running = state.phase else { return }
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        playerTargetX = inputController.clampedPlayerX(
            x,
            sceneWidth: size.width,
            playerHalfWidth: GameplayTuning.playerSize / 2,
            edgePadding: GameplayTuning.playerEdgePadding
        )
    }

    public override func update(_ currentTime: TimeInterval) {
        let dt = deltaTime(for: currentTime)
        guard dt > 0 else { return }

        if case .running = state.phase {
            updateCoffeeBoost(dt: dt)
            updatePlayerPosition(dt: dt)
            elapsedTime += dt
            state.addScore(points: Int(dt * 10))

            let difficulty = difficultyModel.output(for: DifficultyInput(elapsedTime: elapsedTime, score: state.score))
            let spawns = spawner.update(
                dt: dt,
                elapsedTime: elapsedTime,
                score: state.score,
                sceneWidth: size.width,
                difficultyModel: difficultyModel,
                rng: &rng
            )
            spawn(spawns)
            spawnCoffeePowerUpIfNeeded(dt: dt)
            advanceObstacles(dt: dt, speedMultiplier: difficulty.speedMultiplier)
            advanceCoffeePowerUps(dt: dt)
            resolveCoffeePowerUpCollections()
            resolveCollisions()
            updateHUD()
        }
    }

    private func configureBackground() {
        backgroundColor = .systemTeal
        guard let node = SpriteNodeFactory.makeBackgroundNode(sceneSize: size) else { return }
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(node)
        backgroundNode = node
    }

    private func configurePlayer() {
        player.removeFromParent()
        player = SpriteNodeFactory.makePlayerNode(size: GameplayTuning.playerSize)
        player.position = CGPoint(x: size.width / 2, y: GameplayTuning.playerBaselineY)
        player.zPosition = 10
        addChild(player)
        playerTargetX = player.position.x
    }

    private func configureHUD() {
        leftHUDPlate.fillColor = UIColor.black.withAlphaComponent(0.45)
        leftHUDPlate.strokeColor = .clear
        leftHUDPlate.zPosition = 18
        addChild(leftHUDPlate)

        rightHUDPlate.fillColor = UIColor.black.withAlphaComponent(0.45)
        rightHUDPlate.strokeColor = .clear
        rightHUDPlate.zPosition = 18
        addChild(rightHUDPlate)

        scoreLabel.fontSize = 18
        scoreLabel.fontName = "Menlo-Bold"
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 20
        addChild(scoreLabel)

        let livesIcon = SpriteNodeFactory.makeHUDLivesNode(size: GameplayTuning.hudIconSize)
        livesIcon.zPosition = 20
        addChild(livesIcon)
        livesIconNode = livesIcon

        livesLabel.fontSize = 18
        livesLabel.fontName = "Menlo-Bold"
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .top
        livesLabel.zPosition = 20
        addChild(livesLabel)

        let pauseIcon = SpriteNodeFactory.makeHUDPauseNode(size: GameplayTuning.hudIconSize)
        pauseIcon.zPosition = 20
        addChild(pauseIcon)
        pauseIconNode = pauseIcon

        pauseButtonLabel.fontSize = 18
        pauseButtonLabel.fontName = "Menlo-Bold"
        pauseButtonLabel.fontColor = .white
        pauseButtonLabel.horizontalAlignmentMode = .right
        pauseButtonLabel.verticalAlignmentMode = .top
        pauseButtonLabel.yScale = 2.6
        pauseButtonLabel.zPosition = 20
        addChild(pauseButtonLabel)

        pauseStateLabel.fontSize = 28
        pauseStateLabel.fontName = "Menlo-Bold"
        pauseStateLabel.fontColor = .white
        pauseStateLabel.horizontalAlignmentMode = .center
        pauseStateLabel.verticalAlignmentMode = .center
        pauseStateLabel.zPosition = 30
        pauseStateLabel.alpha = 0
        addChild(pauseStateLabel)

        coffeeStatusLabel.fontSize = 14
        coffeeStatusLabel.fontName = "Menlo-Bold"
        coffeeStatusLabel.fontColor = .white
        coffeeStatusLabel.horizontalAlignmentMode = .center
        coffeeStatusLabel.verticalAlignmentMode = .top
        coffeeStatusLabel.zPosition = 20
        coffeeStatusLabel.alpha = 0
        addChild(coffeeStatusLabel)

        layoutHUD()
    }

    private func spawn(_ events: [SpawnEvent]) {
        for event in events {
            let node = ObstacleSystem.makeSpawnedNode(
                for: event,
                sceneHeight: size.height,
                obstacleSize: GameplayTuning.obstacleSize,
                obstacleTypeUserDataKey: GameplayTuning.obstacleTypeUserDataKey
            )
            addChild(node)
        }
    }

    private func advanceObstacles(dt: TimeInterval, speedMultiplier: Double) {
        ObstacleSystem.advanceObstacles(
            in: self,
            dt: dt,
            speedMultiplier: speedMultiplier,
            playerX: player.position.x,
            sceneWidth: size.width,
            obstacleSize: GameplayTuning.obstacleSize,
            managerHomingSpeed: GameplayTuning.managerHomingSpeed,
            obstacleTypeUserDataKey: GameplayTuning.obstacleTypeUserDataKey
        )
    }

    private func resolveCollisions() {
        let hit = ObstacleSystem.removeFirstCollidingObstacle(
            in: self,
            playerFrame: player.frame,
            obstacleInset: GameplayTuning.obstacleCollisionInset,
            playerInset: GameplayTuning.playerCollisionInset
        )

        if hit {
            guard !isCoffeeBoostActive else { return }
            CollisionSystem.handlePlayerHit(state: &state)
            let didGameOver: Bool
            if case .gameOver = state.phase {
                didGameOver = true
            } else {
                didGameOver = false
            }
            feedback.playerHit(in: self, didGameOver: didGameOver)
            updateHUD()
            if case let .gameOver(finalScore) = state.phase {
                onGameOver?(finalScore)
            }
        }
    }

    private func togglePauseState() {
        switch state.phase {
        case .running:
            state.pause()
        case .paused:
            state.resume()
        default:
            return
        }
        updateHUD()
    }

    private func updateHUD() {
        scoreLabel.text = "Score: \(state.score)"
        livesLabel.text = "Lives: \(max(state.lives, 0))"
        if isCoffeeBoostActive {
            let displaySeconds = (coffeeSystem.boostRemaining * 10).rounded() / 10
            coffeeStatusLabel.text = "Coffee x1.6 (\(displaySeconds)s)"
            coffeeStatusLabel.alpha = 1
        } else {
            coffeeStatusLabel.text = ""
            coffeeStatusLabel.alpha = 0
        }
        switch state.phase {
        case .paused:
            pauseButtonLabel.text = "Resume"
            pauseStateLabel.alpha = 1
            pauseIconNode?.alpha = 0.75
        default:
            pauseButtonLabel.text = "Pause"
            pauseStateLabel.alpha = 0
            pauseIconNode?.alpha = 1
        }
        layoutHUD()
    }

    private func layoutHUD() {
        let topInset = max(96, sceneSafeAreaInsets.top + 34)
        let leftInset = max(16, sceneSafeAreaInsets.left + 12)
        let rightInset = max(16, sceneSafeAreaInsets.right + 12)

        leftHUDPlate.path = CGPath(
            roundedRect: CGRect(x: 0, y: 0, width: 170, height: 72),
            cornerWidth: 12,
            cornerHeight: 12,
            transform: nil
        )
        leftHUDPlate.position = CGPoint(x: leftInset - 8, y: size.height - topInset - 44)

        rightHUDPlate.path = CGPath(
            roundedRect: CGRect(x: 0, y: 0, width: 120, height: 64),
            cornerWidth: 12,
            cornerHeight: 12,
            transform: nil
        )
        rightHUDPlate.position = CGPoint(x: size.width - rightInset - 110, y: size.height - topInset - 36)

        scoreLabel.position = CGPoint(x: leftInset, y: size.height - topInset)
        livesIconNode?.position = CGPoint(x: leftInset + 10, y: size.height - (topInset + 36))
        livesLabel.position = CGPoint(x: leftInset + 26, y: size.height - (topInset + 26))
        coffeeStatusLabel.position = CGPoint(x: size.width / 2, y: size.height - topInset)
        pauseButtonLabel.position = CGPoint(x: size.width - rightInset, y: size.height - topInset)
        pauseIconNode?.position = CGPoint(x: size.width - (rightInset + 76), y: size.height - (topInset + 12))
        pauseStateLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    private func updateSafeAreaInsets() {
        sceneSafeAreaInsets = view?.safeAreaInsets ?? .zero
    }

    private func updatePlayerPosition(dt: TimeInterval) {
        let slowdownMultiplier = activeMeetingSlowdownMultiplier()
        let coffeeMultiplier = isCoffeeBoostActive ? GameplayTuning.coffeeSpeedMultiplier : 1
        let responsiveness = GameplayTuning.playerTrackingResponsiveness * slowdownMultiplier * coffeeMultiplier
        let dtFactor = min(CGFloat(dt) * responsiveness, 1)
        player.position.x += (playerTargetX - player.position.x) * dtFactor
    }

    private func activeMeetingSlowdownMultiplier() -> CGFloat {
        ObstacleSystem.meetingSlowdownMultiplier(
            in: self,
            playerPosition: player.position,
            obstacleTypeUserDataKey: GameplayTuning.obstacleTypeUserDataKey,
            radiusX: GameplayTuning.meetingSlowRadiusX,
            radiusY: GameplayTuning.meetingSlowRadiusY,
            slowdownMultiplier: GameplayTuning.meetingSlowMultiplier
        )
    }

    private var isCoffeeBoostActive: Bool {
        coffeeSystem.isBoostActive
    }

    private func resetCoffeePowerUpState() {
        coffeeSystem.reset()
        enumerateChildNodes(withName: "powerup_coffee") { node, _ in
            node.removeFromParent()
        }
    }

    private func updateCoffeeBoost(dt: TimeInterval) {
        coffeeSystem.updateBoost(dt: dt)
    }

    private func spawnCoffeePowerUpIfNeeded(dt: TimeInterval) {
        guard coffeeSystem.updateTimeUntilSpawn(dt: dt) else { return }
        guard childNode(withName: "powerup_coffee") == nil else { return }

        let node = SpriteNodeFactory.makeCoffeePowerUpNode(size: GameplayTuning.coffeePowerUpSize)
        let x = coffeeSystem.randomSpawnX(
            sceneWidth: size.width,
            powerUpSize: GameplayTuning.coffeePowerUpSize
        )
        node.position = CGPoint(x: x, y: size.height + 30)
        node.zPosition = 11
        addChild(node)

        coffeeSystem.scheduleNextSpawn()
    }

    private func advanceCoffeePowerUps(dt: TimeInterval) {
        var removed = false
        enumerateChildNodes(withName: "powerup_coffee") { node, _ in
            node.position.y -= GameplayTuning.coffeeFallSpeed * CGFloat(dt)
            if node.position.y < -60 {
                node.removeFromParent()
                removed = true
            }
        }
        if removed {
            coffeeSystem.handlePowerUpRemovedWithoutCollection()
        }
    }

    private func resolveCoffeePowerUpCollections() {
        var collected = false
        enumerateChildNodes(withName: "powerup_coffee") { node, stop in
            if CollisionSystem.intersects(
                node.frame,
                self.player.frame,
                insetA: GameplayTuning.coffeePowerUpCollisionInset,
                insetB: GameplayTuning.playerCollisionInset
            ) {
                collected = true
                node.removeFromParent()
                stop.pointee = true
            }
        }

        if collected {
            coffeeSystem.handlePowerUpCollected(boostDuration: GameplayTuning.coffeeBoostDuration)
            state.addScore(points: GameplayTuning.coffeePickupScoreBonus)
            feedback.powerUpCollected()
        }
    }

    private func deltaTime(for currentTime: TimeInterval) -> TimeInterval {
        guard let last = lastUpdateTime else {
            lastUpdateTime = currentTime
            return 0
        }

        lastUpdateTime = currentTime
        let dt = currentTime - last
        return min(max(dt, 0), 1.0 / 15.0)
    }
}

private enum GameplayTuning {
    static let coffeePowerUpSeedSalt: UInt64 = 0xC0FFEE5EED
    static let playerSize: CGFloat = 52
    static let obstacleSize: CGFloat = 46
    static let coffeePowerUpSize: CGFloat = 34
    static let playerBaselineY: CGFloat = 78
    static let playerEdgePadding: CGFloat = 8
    static let hudIconSize: CGFloat = 20
    static let playerTrackingResponsiveness: CGFloat = 18
    static let coffeeSpeedMultiplier: CGFloat = 1.6
    static let coffeeBoostDuration: TimeInterval = 4
    static let coffeeSpawnIntervalMin: TimeInterval = 10
    static let coffeeSpawnIntervalMax: TimeInterval = 16
    static let coffeeFallSpeed: CGFloat = 128
    static let coffeePowerUpCollisionInset: CGFloat = 0.16
    static let coffeePickupScoreBonus = 25
    static let meetingSlowMultiplier: CGFloat = 0.55
    static let meetingSlowRadiusX: CGFloat = 120
    static let meetingSlowRadiusY: CGFloat = 190
    static let managerHomingSpeed: CGFloat = 78
    static let obstacleTypeUserDataKey = "obstacle_type"
    static let playerCollisionInset: CGFloat = 0.24
    static let obstacleCollisionInset: CGFloat = 0.20
}
