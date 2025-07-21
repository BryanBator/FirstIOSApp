//
//  UnitConverter.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import Foundation

// Enum für die Kategorien
enum UnitCategory: String, CaseIterable {
    case length = "Länge"
    case weight = "Gewicht"
    case temperature = "Temperatur"
    case currency = "Währung"
    
    // Verfügbare Einheiten pro Kategorie
    var units: [String] {
        switch self {
        case .length:
            return ["Meter", "Kilometer", "Zentimeter", "Fuß", "Zoll", "Meilen"]
        case .weight:
            return ["Kilogramm", "Gramm", "Pfund", "Unzen", "Tonnen"]
        case .temperature:
            return ["Celsius", "Fahrenheit", "Kelvin"]
        case .currency:
            return ["EUR", "USD", "GBP", "CHF", "JPY"]
        }
    }
}

// Umrechnungslogik
class UnitConverter {
    
    // Hauptfunktion für die Umrechnung
    static func convert(value: Double,
                       from fromUnit: String,
                       to toUnit: String,
                       category: UnitCategory) -> Double? {
        
        // Gleiche Einheit? Keine Umrechnung nötig
        if fromUnit == toUnit {
            return value
        }
        
        switch category {
        case .length:
            return convertLength(value: value, from: fromUnit, to: toUnit)
        case .weight:
            return convertWeight(value: value, from: fromUnit, to: toUnit)
        case .temperature:
            return convertTemperature(value: value, from: fromUnit, to: toUnit)
        case .currency:
            // Währung machen wir später mit API
            return nil
        }
    }
    
    // Längen-Umrechnung (alles über Meter als Basis)
    private static func convertLength(value: Double, from: String, to: String) -> Double? {
        // Erst zu Meter konvertieren
        let meters: Double
        switch from {
        case "Meter": meters = value
        case "Kilometer": meters = value * 1000
        case "Zentimeter": meters = value / 100
        case "Fuß": meters = value * 0.3048
        case "Zoll": meters = value * 0.0254
        case "Meilen": meters = value * 1609.34
        default: return nil
        }
        
        // Dann von Meter zur Zieleinheit
        switch to {
        case "Meter": return meters
        case "Kilometer": return meters / 1000
        case "Zentimeter": return meters * 100
        case "Fuß": return meters / 0.3048
        case "Zoll": return meters / 0.0254
        case "Meilen": return meters / 1609.34
        default: return nil
        }
    }
    
    // Gewichts-Umrechnung (alles über Kilogramm als Basis)
    private static func convertWeight(value: Double, from: String, to: String) -> Double? {
        // Erst zu Kilogramm konvertieren
        let kilograms: Double
        switch from {
        case "Kilogramm": kilograms = value
        case "Gramm": kilograms = value / 1000
        case "Pfund": kilograms = value * 0.453592
        case "Unzen": kilograms = value * 0.0283495
        case "Tonnen": kilograms = value * 1000
        default: return nil
        }
        
        // Dann von Kilogramm zur Zieleinheit
        switch to {
        case "Kilogramm": return kilograms
        case "Gramm": return kilograms * 1000
        case "Pfund": return kilograms / 0.453592
        case "Unzen": return kilograms / 0.0283495
        case "Tonnen": return kilograms / 1000
        default: return nil
        }
    }
    
    // Temperatur-Umrechnung
    private static func convertTemperature(value: Double, from: String, to: String) -> Double? {
        // Erst zu Celsius konvertieren
        let celsius: Double
        switch from {
        case "Celsius": celsius = value
        case "Fahrenheit": celsius = (value - 32) * 5/9
        case "Kelvin": celsius = value - 273.15
        default: return nil
        }
        
        // Dann von Celsius zur Zieleinheit
        switch to {
        case "Celsius": return celsius
        case "Fahrenheit": return celsius * 9/5 + 32
        case "Kelvin": return celsius + 273.15
        default: return nil
        }
    }
}
