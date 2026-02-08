import Foundation

public protocol HighScoreStoring {
    func loadScores() -> [Int]
    @discardableResult
    func record(score: Int) -> [Int]
    func clear()
}

public final class HighScoreStore: HighScoreStoring {
    private let userDefaults: UserDefaults
    private let key: String
    private let maxEntries: Int

    public init(
        userDefaults: UserDefaults = .standard,
        key: String = "office_dodge.high_scores",
        maxEntries: Int = 10
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.maxEntries = max(1, maxEntries)
    }

    public func loadScores() -> [Int] {
        let rawScores = userDefaults.array(forKey: key) as? [Int] ?? []
        let normalized = normalizedScores(from: rawScores)
        if normalized != rawScores {
            userDefaults.set(normalized, forKey: key)
        }
        return normalized
    }

    @discardableResult
    public func record(score: Int) -> [Int] {
        guard score > 0 else { return loadScores() }

        var scores = loadScores()
        scores.append(score)
        let normalized = normalizedScores(from: scores)
        userDefaults.set(normalized, forKey: key)
        return normalized
    }

    public func clear() {
        userDefaults.removeObject(forKey: key)
    }

    private func normalizedScores(from scores: [Int]) -> [Int] {
        Array(
            scores
                .filter { $0 > 0 }
                .sorted(by: >)
                .prefix(maxEntries)
        )
    }
}
