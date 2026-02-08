#!/usr/bin/env swift
//
// Generate language-agnostic and Italian translation JSON files from LiquoreData_All.json
//

import Foundation

struct LegacyReminder: Codable {
    let title: String
    let startDay: Int
    let repeatEveryDays: Int?
    let durationDays: Int
    let notes: String
}

struct LegacyIngredient: Codable {
    let nome: String
    let quantita: Double
    let unita: String
}

struct LegacyRecipe: Codable {
    let id: Int
    let nome: String
    let categoria: String
    let icona: String
    let detailImage: String
    let isPaid: Bool?
    let tier: [String]?
    let subTitle: String
    let history: String?
    let ingredientiBase: [LegacyIngredient]
    let preparazione: [String]
    let timerGiorni: Int?
    let comeServire: String
    let difficolta: Int
    let reminders: [LegacyReminder]?
    let expertNotes: LegacyExpertNotes?
    let bestBeforeMonths: Double?
    let storage: LegacyStorage?
    let peakSeason: String?
    let suggestedSeasons: [String]?
}

struct BaseIngredient: Codable {
    let quantita: Double
    let unita: String
}

struct BaseReminder: Codable {
    let startDay: Int
    let repeatEveryDays: Int?
    let durationDays: Int
}

struct BaseRecipe: Codable {
    let id: Int
    let categoria: String
    let icona: String
    let detailImage: String
    let isPaid: Bool?
    let tier: [String]?
    let ingredientiBase: [BaseIngredient]
    let timerGiorni: Int?
    let difficolta: Int
    let reminders: [BaseReminder]
    let bestBeforeMonths: Double?
    let storage: BaseStorage?
    let peakSeason: String?
    let suggestedSeasons: [String]?
    let suggestedGlassId: String
}

struct TranslationIngredient: Codable {
    let nome: String
}

struct TranslationReminder: Codable {
    let title: String
    let notes: String
}

struct LegacyExpertNotes: Codable {
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

struct TranslationExpertNotes: Codable {
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

struct LegacyStorage: Codable {
    let container: String
    let keepAwayFrom: [String]
    let notes: String
    let recommendedLocations: [String]
    let shakeBeforeUse: Bool
}

struct BaseStorage: Codable {
    let shakeBeforeUse: Bool
}

struct TranslationStorage: Codable {
    let container: String
    let keepAwayFrom: [String]
    let notes: String
    let recommendedLocations: [String]
}

struct TranslationRecipe: Codable {
    let nome: String
    let subTitle: String
    let history: String?
    let ingredientiBase: [TranslationIngredient]
    let preparazione: [String]
    let comeServire: String
    let reminders: [TranslationReminder]
    let expertNotes: TranslationExpertNotes?
    let storage: TranslationStorage?
}

struct TranslationsFile: Codable {
    let recipes: [String: TranslationRecipe]
}

func loadLegacyRecipes(from path: String) throws -> [LegacyRecipe] {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([LegacyRecipe].self, from: data)
}

struct GlasswareData: Codable {
    struct Glass: Codable { let key: String }
    struct ServingSuggestions: Codable {
        let byLiqueurCategory: [String: [String]]
    }

    let glassware: [Glass]
    let servingSuggestions: ServingSuggestions
}

func loadGlasswareData(from path: String) throws -> GlasswareData {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(GlasswareData.self, from: data)
}

func suggestedGlassId(for category: String, glassware: GlasswareData) -> String {
    let allowed = Set(glassware.glassware.map(\.key))
    if let first = glassware.servingSuggestions.byLiqueurCategory[category]?.first, allowed.contains(first) {
        return first
    }
    if let fallback = glassware.glassware.first?.key {
        return fallback
    }
    return "cordial_glass"
}

func makeBaseRecipes(from legacy: [LegacyRecipe], glassware: GlasswareData) -> [BaseRecipe] {
    legacy.map { recipe in
        let baseIngredients = recipe.ingredientiBase.map { BaseIngredient(quantita: $0.quantita, unita: $0.unita) }
        let baseReminders = (recipe.reminders ?? []).map {
            BaseReminder(startDay: $0.startDay, repeatEveryDays: $0.repeatEveryDays, durationDays: $0.durationDays)
        }
        let baseStorage = recipe.storage.map { BaseStorage(shakeBeforeUse: $0.shakeBeforeUse) }
        return BaseRecipe(
            id: recipe.id,
            categoria: recipe.categoria,
            icona: recipe.icona,
            detailImage: recipe.detailImage,
            isPaid: recipe.isPaid,
            tier: recipe.tier,
            ingredientiBase: baseIngredients,
            timerGiorni: recipe.timerGiorni,
            difficolta: recipe.difficolta,
            reminders: baseReminders,
            bestBeforeMonths: recipe.bestBeforeMonths,
            storage: baseStorage,
            peakSeason: recipe.peakSeason,
            suggestedSeasons: recipe.suggestedSeasons,
            suggestedGlassId: suggestedGlassId(for: recipe.categoria, glassware: glassware)
        )
    }
}

func makeTranslationExpertNotes(from notes: LegacyExpertNotes?) -> TranslationExpertNotes? {
    notes.map {
        TranslationExpertNotes(
            extraction: $0.extraction,
            commonMistakes: $0.commonMistakes,
            filtration: $0.filtration,
            aging: $0.aging,
            recovery: $0.recovery,
            balancing: $0.balancing,
            variations: $0.variations,
            safety: $0.safety,
            evolution: $0.evolution,
            serving: $0.serving,
            tasting: $0.tasting,
            insight: $0.insight
        )
    }
}

func makeTranslationStorage(from storage: LegacyStorage?) -> TranslationStorage? {
    storage.map {
        TranslationStorage(
            container: $0.container,
            keepAwayFrom: $0.keepAwayFrom,
            notes: $0.notes,
            recommendedLocations: $0.recommendedLocations
        )
    }
}

func makeTranslations(from legacy: [LegacyRecipe]) -> TranslationsFile {
    let dictionary = Dictionary(uniqueKeysWithValues: legacy.map { recipe in
        let ingredients = recipe.ingredientiBase.map { TranslationIngredient(nome: $0.nome) }
        let reminders = (recipe.reminders ?? []).map { TranslationReminder(title: $0.title, notes: $0.notes) }
        let notes = makeTranslationExpertNotes(from: recipe.expertNotes)
        let storage = makeTranslationStorage(from: recipe.storage)
        let translation = TranslationRecipe(
            nome: recipe.nome,
            subTitle: recipe.subTitle,
            history: recipe.history,
            ingredientiBase: ingredients,
            preparazione: recipe.preparazione,
            comeServire: recipe.comeServire,
            reminders: reminders,
            expertNotes: notes,
            storage: storage
        )
        return ("\(recipe.id)", translation)
    })
    return TranslationsFile(recipes: dictionary)
}

func writeJSON<T: Encodable>(_ value: T, to path: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(value)
    try data.write(to: URL(fileURLWithPath: path))
}

let root = FileManager.default.currentDirectoryPath
let legacyPath = "\(root)/Liquore/Jsons/LiquoreData_All.json"
let baseOutput = "\(root)/Liquore/Jsons/recipes.json"
let translationsOutputIt = "\(root)/Liquore/Jsons/translations_it.json"
let glasswarePath = "\(root)/Liquore/Jsons/glassware.data.json"

do {
    let legacy = try loadLegacyRecipes(from: legacyPath)
    let glassware = try loadGlasswareData(from: glasswarePath)
    let baseRecipes = makeBaseRecipes(from: legacy, glassware: glassware)
    let translations = makeTranslations(from: legacy)
    
    try writeJSON(baseRecipes, to: baseOutput)
    try writeJSON(translations, to: translationsOutputIt)
    
    print("Generated recipes.json and translations_it.json")
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
