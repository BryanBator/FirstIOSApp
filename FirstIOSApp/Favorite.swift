//
//  Favorite.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import Foundation

// Model für einen Favoriten
struct Favorite: Identifiable, Codable, Equatable {
    let id = UUID()
    let category: String  // Wir speichern als String für Codable
    let fromUnit: String
    let toUnit: String
    let name: String
    let createdAt: Date
    
    // Computed property für die Kategorie
    var unitCategory: UnitCategory? {
        return UnitCategory.allCases.first { $0.rawValue == category }
    }
    
    // Initialisator
    init(category: UnitCategory, fromUnit: String, toUnit: String, name: String) {
        self.category = category.rawValue
        self.fromUnit = fromUnit
        self.toUnit = toUnit
        self.name = name
        self.createdAt = Date()
    }
}

// Manager für Favoriten (Singleton)
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favorites: [Favorite] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "savedFavorites"
    
    init() {
        loadFavorites()
    }
    
    // Lade Favoriten aus UserDefaults
    func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Favorite].self, from: data) {
            favorites = decoded
        }
    }
    
    // Speichere Favoriten in UserDefaults
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    // Füge einen Favoriten hinzu
    func addFavorite(_ favorite: Favorite) {
        // Prüfe ob bereits vorhanden
        let exists = favorites.contains { fav in
            fav.category == favorite.category &&
            fav.fromUnit == favorite.fromUnit &&
            fav.toUnit == favorite.toUnit
        }
        
        if !exists {
            favorites.append(favorite)
            saveFavorites()
        }
    }
    
    // Entferne einen Favoriten
    func removeFavorite(_ favorite: Favorite) {
        favorites.removeAll { $0.id == favorite.id }
        saveFavorites()
    }
    
    // Prüfe ob Kombination bereits Favorit ist
    func isFavorite(category: UnitCategory, fromUnit: String, toUnit: String) -> Bool {
        return favorites.contains { fav in
            fav.category == category.rawValue &&
            fav.fromUnit == fromUnit &&
            fav.toUnit == toUnit
        }
    }
    
    // Toggle Favorit
    func toggleFavorite(category: UnitCategory, fromUnit: String, toUnit: String, name: String) {
        if let existingFavorite = favorites.first(where: { fav in
            fav.category == category.rawValue &&
            fav.fromUnit == fromUnit &&
            fav.toUnit == toUnit
        }) {
            removeFavorite(existingFavorite)
        } else {
            let newFavorite = Favorite(
                category: category,
                fromUnit: fromUnit,
                toUnit: toUnit,
                name: name
            )
            addFavorite(newFavorite)
        }
    }
}
