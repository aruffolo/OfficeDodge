import Foundation

@MainActor
public protocol AppRouting: AnyObject {
    var path: [AppRoute] { get set }
    var presentedSheet: AppRoute? { get set }

    func push(_ route: AppRoute)
    @discardableResult
    func pop() -> AppRoute?
    func popToRoot()
    func present(_ route: AppRoute)
    func dismissSheet()
}
