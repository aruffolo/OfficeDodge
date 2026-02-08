import Foundation

public enum AppConfiguration {
    public static var loggingEnabled: Bool {
        bool(forInfoPlistKey: "LoggingEnabled", defaultValue: false)
    }

    static func bool(forInfoPlistKey key: String, defaultValue: Bool) -> Bool {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) else {
            return defaultValue
        }

        if let bool = value as? Bool {
            return bool
        }

        if let string = value as? String {
            switch string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "1", "true", "yes", "y", "on":
                return true
            case "0", "false", "no", "n", "off":
                return false
            default:
                return defaultValue
            }
        }

        if let number = value as? NSNumber {
            return number.boolValue
        }

        return defaultValue
    }
}
