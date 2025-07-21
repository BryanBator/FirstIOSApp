//
//  CurrencyAPI.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import Foundation

// Model für die API-Antwort
struct ExchangeRates: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
}

// Manager für Währungskurse
class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var lastUpdate: Date?
    @Published var errorMessage: String?
    
    // Wir nutzen die kostenlose API von exchangerate-api.com
    // Alternative: fixer.io, currencyapi.com (beide brauchen API Key)
    private let baseURL = "https://api.exchangerate-api.com/v4/latest/"
    
    init() {
        // Lade gespeicherte Kurse falls vorhanden
        loadCachedRates()
        // Aktualisiere Kurse
        fetchExchangeRates()
    }
    
    // Hole aktuelle Kurse von der API
    func fetchExchangeRates() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)EUR") else {
            errorMessage = "Ungültige URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Netzwerkfehler: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Keine Daten empfangen"
                    return
                }
                
                do {
                    let decodedRates = try JSONDecoder().decode(ExchangeRates.self, from: data)
                    self?.exchangeRates = decodedRates.rates
                    self?.lastUpdate = Date()
                    self?.saveRatesToCache(decodedRates.rates)
                } catch {
                    self?.errorMessage = "Fehler beim Verarbeiten der Daten"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    // Währungsumrechnung
    func convert(amount: Double, from: String, to: String) -> Double? {
        // EUR als Basis
        guard let fromRate = exchangeRates[from],
              let toRate = exchangeRates[to] else {
            return nil
        }
        
        // Konvertiere erst zu EUR, dann zur Zielwährung
        let euroAmount = amount / fromRate
        return euroAmount * toRate
    }
    
    // Speichere Kurse lokal für Offline-Nutzung
    private func saveRatesToCache(_ rates: [String: Double]) {
        UserDefaults.standard.set(rates, forKey: "cachedExchangeRates")
        UserDefaults.standard.set(Date(), forKey: "lastRatesUpdate")
    }
    
    // Lade gespeicherte Kurse
    private func loadCachedRates() {
        if let cached = UserDefaults.standard.dictionary(forKey: "cachedExchangeRates") as? [String: Double] {
            exchangeRates = cached
        }
        
        if let lastUpdate = UserDefaults.standard.object(forKey: "lastRatesUpdate") as? Date {
            self.lastUpdate = lastUpdate
        }
        
        // Füge EUR hinzu (Basis-Währung)
        exchangeRates["EUR"] = 1.0
    }
    
    // Formatiertes Datum der letzten Aktualisierung
    var formattedLastUpdate: String {
        guard let lastUpdate = lastUpdate else { return "Noch nicht aktualisiert" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: lastUpdate)
    }
    
    // Prüfe ob Kurse veraltet sind (älter als 1 Tag)
    var ratesAreOutdated: Bool {
        guard let lastUpdate = lastUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > 86400 // 24 Stunden
    }
}
