//
//  History.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import Foundation

// Model für einen Verlaufseintrag
struct HistoryEntry: Identifiable, Codable {
    let id = UUID()
    let value: Double
    let result: Double
    let fromUnit: String
    let toUnit: String
    let category: String
    let timestamp: Date
    
    // Formatierte Strings für die Anzeige
    var formattedValue: String {
        return String(format: "%.2f", value)
    }
    
    var formattedResult: String {
        return String(format: "%.2f", result)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: timestamp)
    }
    
    var summary: String {
        return "\(formattedValue) \(fromUnit) = \(formattedResult) \(toUnit)"
    }
}

// Manager für den Verlauf
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var entries: [HistoryEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "conversionHistory"
    private let maxEntries = 50 // Maximal 50 Einträge speichern
    
    init() {
        loadHistory()
    }
    
    // Lade Verlauf aus UserDefaults
    func loadHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entries = decoded
        }
    }
    
    // Speichere Verlauf in UserDefaults
    private func saveHistory() {
        // Behalte nur die neuesten maxEntries
        let entriesToSave = Array(entries.prefix(maxEntries))
        
        if let encoded = try? JSONEncoder().encode(entriesToSave) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }
    
    // Füge einen neuen Eintrag hinzu
    func addEntry(value: Double, result: Double, fromUnit: String, toUnit: String, category: UnitCategory) {
        let entry = HistoryEntry(
            value: value,
            result: result,
            fromUnit: fromUnit,
            toUnit: toUnit,
            category: category.rawValue,
            timestamp: Date()
        )
        
        // Füge am Anfang ein (neueste zuerst)
        entries.insert(entry, at: 0)
        saveHistory()
    }
    
    // Lösche einen einzelnen Eintrag
    func deleteEntry(_ entry: HistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveHistory()
    }
    
    // Lösche den gesamten Verlauf
    func clearHistory() {
        entries.removeAll()
        saveHistory()
    }
    
    // Gruppiere Einträge nach Datum
    func groupedEntries() -> [(key: String, value: [HistoryEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            // Gruppiere nach Tag
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: entry.timestamp)
        }
        
        // Sortiere die Gruppen nach Datum (neueste zuerst)
        return grouped.sorted { first, second in
            guard let firstEntry = first.value.first,
                  let secondEntry = second.value.first else { return false }
            return firstEntry.timestamp > secondEntry.timestamp
        }
    }
}
