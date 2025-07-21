//
//  ContentView.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

struct ContentView: View {
    @State private var inputValue = ""
    @State private var outputValue = ""
    @State private var selectedCategory = "Länge"
    
    let categories = ["Länge", "Gewicht", "Temperatur", "Währung"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Kategorie-Auswahl
                Picker("Kategorie", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Input-Bereich
                VStack(alignment: .leading, spacing: 10) {
                    Text("Von:")
                        .font(.headline)
                    
                    HStack {
                        TextField("Wert eingeben", text: $inputValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        // Einheit-Auswahl kommt später
                        Text("Meter")
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Umrechnen-Button
                Button(action: {
                    // TODO: Umrechnung implementieren
                    outputValue = inputValue // Erstmal nur kopieren
                }) {
                    Text("Umrechnen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Output-Bereich
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nach:")
                        .font(.headline)
                    
                    HStack {
                        Text(outputValue.isEmpty ? "Ergebnis" : outputValue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        // Einheit-Auswahl kommt später
                        Text("Fuß")
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Einheiten-Umrechner")
        }
    }
}
#Preview {
    ContentView()
}
