public enum AppRoute: Hashable, Sendable {
    case menu
    case game
    case gameOver(score: Int)
    case settings
}
