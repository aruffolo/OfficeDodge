import CoreGraphics
import OfficeDodgeCore
import XCTest

final class CollisionSystemTests: XCTestCase {
    func testIntersectsWithoutInsetBehavesLikeRectIntersection() {
        let a = CGRect(x: 0, y: 0, width: 100, height: 100)
        let b = CGRect(x: 90, y: 0, width: 100, height: 100)

        XCTAssertTrue(CollisionSystem.intersects(a, b))
    }

    func testIntersectsWithInsetReducesFalsePositiveContacts() {
        let a = CGRect(x: 0, y: 0, width: 100, height: 100)
        let b = CGRect(x: 85, y: 0, width: 100, height: 100)

        XCTAssertFalse(CollisionSystem.intersects(a, b, insetA: 0.20, insetB: 0.20))
    }

    func testIntersectsClampsInsetFraction() {
        let a = CGRect(x: 0, y: 0, width: 100, height: 100)
        let b = CGRect(x: 50, y: 50, width: 100, height: 100)

        XCTAssertFalse(CollisionSystem.intersects(a, b, insetA: 3, insetB: 3))
    }
}
