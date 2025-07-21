import SwiftUI

struct ContentView: View {
    @State private var inputValue = ""
    @State private var selectedCategory = UnitCategory.length
    @State private var fromUnit = "Meter"
    @State private var toUnit = "Fuß"
    
    // Computed property für das Ergebnis
    private var convertedValue: String {
        guard let value = Double(inputValue) else { return "Ungültige Eingabe" }
        
        if let result = UnitConverter.convert(value: value,
                                             from: fromUnit,
                                             to: toUnit,
                                             category: selectedCategory) {
            // Formatierung auf 2 Nachkommastellen
            return String(format: "%.2f", result)
        } else {
            return "Fehler bei Umrechnung"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Kategorie-Auswahl
                Picker("Kategorie", selection: $selectedCategory) {
                    ForEach(UnitCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedCategory) { oldValue, newValue in
                    // Setze Einheiten zurück wenn Kategorie wechselt
                    fromUnit = newValue.units.first ?? ""
                    toUnit = newValue.units.last ?? ""
                }
                
                // Input-Bereich
                VStack(alignment: .leading, spacing: 10) {
                    Text("Von:")
                        .font(.headline)
                    
                    HStack {
                        TextField("Wert eingeben", text: $inputValue)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        Picker("Von Einheit", selection: $fromUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                }
                .padding(.horizontal)
                
                // Tausch-Button
                Button(action: {
                    let temp = fromUnit
                    fromUnit = toUnit
                    toUnit = temp
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
                
                // Output-Bereich
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nach:")
                        .font(.headline)
                    
                    HStack {
                        Text(inputValue.isEmpty ? "Ergebnis" : convertedValue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Picker("Nach Einheit", selection: $toUnit) {
                            ForEach(selectedCategory.units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                }
                .padding(.horizontal)
                
                // Schnell-Aktionen
                HStack(spacing: 20) {
                    Button("Löschen") {
                        inputValue = ""
                    }
                    .foregroundColor(.red)
                    
                    Button("Kopieren") {
                        UIPasteboard.general.string = convertedValue
                    }
                    .foregroundColor(.blue)
                    .disabled(inputValue.isEmpty)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Einheiten-Umrechner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Hier kommt später das Einstellungs-Menü
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onTapGesture {
            // Verstecke Keyboard beim Tippen außerhalb
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                          to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
}
