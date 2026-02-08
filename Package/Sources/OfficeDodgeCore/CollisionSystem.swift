import CoreGraphics
import Foundation

public enum CollisionSystem {
    public static func intersects(
        _ a: CGRect,
        _ b: CGRect,
        insetA: CGFloat = 0,
        insetB: CGFloat = 0
    ) -> Bool {
        let adjustedA = inset(a, fraction: insetA)
        let adjustedB = inset(b, fraction: insetB)
        return adjustedA.intersects(adjustedB)
    }

    public static func handlePlayerHit(state: inout GameState) {
        state.registerCollision()
    }

    private static func inset(_ rect: CGRect, fraction: CGFloat) -> CGRect {
        let clampedFraction = min(max(fraction, 0), 0.95)
        let dx = rect.width * clampedFraction * 0.5
        let dy = rect.height * clampedFraction * 0.5
        return rect.insetBy(dx: dx, dy: dy)
    }
}
