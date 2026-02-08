import CoreGraphics

public struct InputController {
    public init() {}

    public func clampedPlayerX(
        _ proposedX: CGFloat,
        sceneWidth: CGFloat,
        playerHalfWidth: CGFloat,
        edgePadding: CGFloat = 8
    ) -> CGFloat {
        let minX = playerHalfWidth + edgePadding
        let maxX = max(minX, sceneWidth - playerHalfWidth - edgePadding)
        return min(max(proposedX, minX), maxX)
    }
}
