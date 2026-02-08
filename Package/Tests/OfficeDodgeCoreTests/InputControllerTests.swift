import CoreGraphics
import OfficeDodgeCore
import XCTest

final class InputControllerTests: XCTestCase {
    private let controller = InputController()

    func testClampedPlayerXHonorsLeftBound() {
        let value = controller.clampedPlayerX(-100, sceneWidth: 390, playerHalfWidth: 26)
        XCTAssertEqual(value, 34, accuracy: 0.000_1)
    }

    func testClampedPlayerXHonorsRightBound() {
        let value = controller.clampedPlayerX(999, sceneWidth: 390, playerHalfWidth: 26)
        XCTAssertEqual(value, 356, accuracy: 0.000_1)
    }

    func testClampedPlayerXReturnsUnchangedValueWhenInsideBounds() {
        let value = controller.clampedPlayerX(200, sceneWidth: 390, playerHalfWidth: 26)
        XCTAssertEqual(value, 200, accuracy: 0.000_1)
    }

    func testClampedPlayerXUsesSafeMinimumWhenSceneIsTooNarrow() {
        let value = controller.clampedPlayerX(20, sceneWidth: 50, playerHalfWidth: 30, edgePadding: 8)
        XCTAssertEqual(value, 38, accuracy: 0.000_1)
    }
}
