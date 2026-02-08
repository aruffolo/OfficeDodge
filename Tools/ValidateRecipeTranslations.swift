#!/usr/bin/env swift

import Foundation

struct BaseRecipe: Decodable {
    struct Ingredient: Decodable { let quantita: Double; let unita: String }
    struct Reminder: Decodable { let startDay: Int; let repeatEveryDays: Int?; let durationDays: Int }
    struct Storage: Decodable { let shakeBeforeUse: Bool }

    let id: Int
    let ingredientiBase: [Ingredient]
    let reminders: [Reminder]
    let storage: Storage?
}

struct TranslationsFile: Decodable {
    struct ExpertNotesTranslation: Decodable {
        let extraction: [String]?
        let commonMistakes: [String]?
        let filtration: [String]?
        let aging: [String]?
        let recovery: [String]?
        let balancing: [String]?
        let variations: [String]?
        let safety: [String]?
        let evolution: [String]?
        let serving: [String]?
        let tasting: [String]?
        let insight: [String]?
    }

    struct StorageTranslation: Decodable {
        let container: String
        let keepAwayFrom: [String]
        let notes: String
        let recommendedLocations: [String]
    }

    struct RecipeTranslation: Decodable {
        struct IngredientTranslation: Decodable { let nome: String }
        struct ReminderTranslation: Decodable { let title: String; let notes: String }

        let nome: String
        let subTitle: String
        let history: String?
        let ingredientiBase: [IngredientTranslation]
        let preparazione: [String]
        let comeServire: String
        let reminders: [ReminderTranslation]
        let expertNotes: ExpertNotesTranslation?
        let storage: StorageTranslation?
    }

    let recipes: [String: RecipeTranslation]
}

struct Config {
    let recipesPath: URL
    let canonicalTranslationsPath: URL
    let translationPaths: [URL]
}

func defaultRepoRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // Tools/
        .deletingLastPathComponent() // repo root
}

func parseArgs(repoRoot: URL) -> Config {
    var recipesPath = repoRoot.appending(path: "Package/Sources/Resources/Resources/Jsons/recipes.json")
    var canonicalTranslationsPath = repoRoot.appending(path: "Package/Sources/Resources/Resources/Jsons/translations_it.json")
    var translationPaths: [URL] = []

    var idx = 1
    let args = CommandLine.arguments
    while idx < args.count {
        switch args[idx] {
        case "--recipes":
            idx += 1
            guard idx < args.count else { usageAndExit() }
            recipesPath = URL(fileURLWithPath: args[idx])
        case "--canonical":
            idx += 1
            guard idx < args.count else { usageAndExit() }
            canonicalTranslationsPath = URL(fileURLWithPath: args[idx])
        case "--help", "-h":
            usageAndExit(exitCode: 0)
        default:
            translationPaths.append(URL(fileURLWithPath: args[idx]))
        }
        idx += 1
    }

    if translationPaths.isEmpty {
        let dir = repoRoot.appending(path: "Package/Sources/Resources/Resources/Jsons")
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        translationPaths = files
            .filter { $0.lastPathComponent.hasPrefix("translations_") && $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    return Config(
        recipesPath: recipesPath,
        canonicalTranslationsPath: canonicalTranslationsPath,
        translationPaths: translationPaths
    )
}

func usageAndExit(exitCode: Int32 = 2) -> Never {
    let script = (CommandLine.arguments.first as NSString?)?.lastPathComponent ?? "ValidateRecipeTranslations.swift"
    fputs(
        """
        Usage:
          \(script) [--recipes <recipes.json>] [--canonical <translations_it.json>] [translations_*.json ...]
        
        Defaults:
          --recipes    Package/Sources/Resources/Resources/Jsons/recipes.json
          --canonical  Package/Sources/Resources/Resources/Jsons/translations_it.json
          (If no translation files provided, validates all translations_*.json in the Jsons folder.)
        
        """,
        stderr
    )
    exit(exitCode)
}

func decodeJSON<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}

func isBlank(_ s: String) -> Bool { s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
func nonBlankList(_ xs: [String]) -> Bool { !xs.isEmpty && xs.allSatisfy { !isBlank($0) } }

func validate(
    baseRecipes: [Int: BaseRecipe],
    canonical: [String: TranslationsFile.RecipeTranslation],
    translationsFile: TranslationsFile,
    fileName: String
) -> [String] {
    var errors: [String] = []

    let baseIds = Set(baseRecipes.keys.map(String.init))
    let translationIds = Set(translationsFile.recipes.keys)

    let missing = baseIds.subtracting(translationIds).sorted { Int($0)! < Int($1)! }
    if !missing.isEmpty {
        errors.append("\(fileName): missing recipe ids: \(missing.joined(separator: ", "))")
    }

    let extra = translationIds.subtracting(baseIds).sorted()
    if !extra.isEmpty {
        errors.append("\(fileName): extra recipe ids not in recipes.json: \(extra.joined(separator: ", "))")
    }

    for (id, base) in baseRecipes.sorted(by: { $0.key < $1.key }) {
        let key = "\(id)"
        guard let tr = translationsFile.recipes[key] else { continue }

        if isBlank(tr.nome) { errors.append("\(fileName): recipe \(id): empty nome") }
        if isBlank(tr.subTitle) { errors.append("\(fileName): recipe \(id): empty subTitle") }
        if isBlank(tr.comeServire) { errors.append("\(fileName): recipe \(id): empty comeServire") }
        if let history = tr.history, isBlank(history) { errors.append("\(fileName): recipe \(id): history is blank") }

        if tr.ingredientiBase.count != base.ingredientiBase.count {
            errors.append("\(fileName): recipe \(id): ingredientiBase count \(tr.ingredientiBase.count) != base \(base.ingredientiBase.count)")
        }
        if tr.reminders.count != base.reminders.count {
            errors.append("\(fileName): recipe \(id): reminders count \(tr.reminders.count) != base \(base.reminders.count)")
        }

        if tr.ingredientiBase.isEmpty { errors.append("\(fileName): recipe \(id): ingredientiBase is empty") }
        if !tr.ingredientiBase.allSatisfy({ !isBlank($0.nome) }) {
            errors.append("\(fileName): recipe \(id): ingredientiBase contains blank nome")
        }

        if tr.preparazione.isEmpty { errors.append("\(fileName): recipe \(id): preparazione is empty") }
        if !tr.preparazione.allSatisfy({ !isBlank($0) }) {
            errors.append("\(fileName): recipe \(id): preparazione contains blank steps")
        }

        if tr.reminders.isEmpty { errors.append("\(fileName): recipe \(id): reminders is empty") }
        if !tr.reminders.allSatisfy({ !isBlank($0.title) && !isBlank($0.notes) }) {
            errors.append("\(fileName): recipe \(id): reminders contains blank title/notes")
        }

        if base.storage != nil {
            guard let storage = tr.storage else {
                errors.append("\(fileName): recipe \(id): missing storage (required by base)")
                continue
            }
            if isBlank(storage.container) { errors.append("\(fileName): recipe \(id): storage.container is blank") }
            if isBlank(storage.notes) { errors.append("\(fileName): recipe \(id): storage.notes is blank") }
            if !nonBlankList(storage.keepAwayFrom) { errors.append("\(fileName): recipe \(id): storage.keepAwayFrom empty/blank") }
            if !nonBlankList(storage.recommendedLocations) { errors.append("\(fileName): recipe \(id): storage.recommendedLocations empty/blank") }
        }

        if let canonicalRecipe = canonical[key], tr.preparazione.count != canonicalRecipe.preparazione.count {
            errors.append("\(fileName): recipe \(id): preparazione count \(tr.preparazione.count) != canonical \(canonicalRecipe.preparazione.count)")
        }
    }

    return errors
}

let repoRoot = defaultRepoRoot()
let config = parseArgs(repoRoot: repoRoot)

do {
    let baseList = try decodeJSON([BaseRecipe].self, from: config.recipesPath)
    let baseById = Dictionary(uniqueKeysWithValues: baseList.map { ($0.id, $0) })
    let canonicalFile = try decodeJSON(TranslationsFile.self, from: config.canonicalTranslationsPath)

    var allErrors: [String] = []
    for translationPath in config.translationPaths {
        let fileName = translationPath.lastPathComponent
        let file = try decodeJSON(TranslationsFile.self, from: translationPath)
        allErrors.append(contentsOf: validate(
            baseRecipes: baseById,
            canonical: canonicalFile.recipes,
            translationsFile: file,
            fileName: fileName
        ))
    }

    if allErrors.isEmpty {
        print("OK: validated \(config.translationPaths.count) translation file(s)")
        exit(0)
    }

    for err in allErrors {
        print("ERROR:", err)
    }
    print("FAILED: \(allErrors.count) error(s)")
    exit(1)
} catch {
    print("FAILED: \(error)")
    exit(1)
}
