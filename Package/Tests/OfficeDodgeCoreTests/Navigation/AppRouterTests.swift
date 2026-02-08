import OfficeDodgeCore
import XCTest

@MainActor
final class AppRouterTests: XCTestCase {
    func testPushPopAndPopToRoot() {
        let router = AppRouter()

        router.push(.menu)
        router.push(.game)

        XCTAssertEqual(router.path, [.menu, .game])
        XCTAssertEqual(router.pop(), .game)
        XCTAssertEqual(router.path, [.menu])

        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testPresentAndDismissSheet() {
        let router = AppRouter()

        router.present(.settings)
        XCTAssertEqual(router.presentedSheet, .settings)

        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
    }
}
