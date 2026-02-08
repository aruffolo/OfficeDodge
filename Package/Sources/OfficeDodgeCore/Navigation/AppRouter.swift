import Foundation
import Observation

@MainActor
@Observable
public final class AppRouter: AppRouting {
    public var path: [AppRoute] = []
    public var presentedSheet: AppRoute?

    public init() {}

    public func push(_ route: AppRoute) {
        path.append(route)
    }

    @discardableResult
    public func pop() -> AppRoute? {
        path.popLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func present(_ route: AppRoute) {
        presentedSheet = route
    }

    public func dismissSheet() {
        presentedSheet = nil
    }
}
