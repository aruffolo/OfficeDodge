import Foundation
import OSLog

public struct AppLogger: Sendable {
    private let logger: Logger

    public init(category: String) {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.aruffolo.officedodge", category: category)
    }

    public static let app = AppLogger(category: "app")
    public static let gameplay = AppLogger(category: "gameplay")
    public static let collision = AppLogger(category: "collision")
    public static let spawning = AppLogger(category: "spawning")

    public static func category(_ value: String) -> AppLogger {
        AppLogger(category: value)
    }

    public func infoEnabled(_ message: @autoclosure () -> String) {
        guard AppConfiguration.loggingEnabled else { return }
        let text = message()
        logger.info("\(text, privacy: .public)")
    }

    public func warningEnabled(_ message: @autoclosure () -> String) {
        guard AppConfiguration.loggingEnabled else { return }
        let text = message()
        logger.warning("\(text, privacy: .public)")
    }

    public func errorEnabled(_ message: @autoclosure () -> String) {
        guard AppConfiguration.loggingEnabled else { return }
        let text = message()
        logger.error("\(text, privacy: .public)")
    }
}
