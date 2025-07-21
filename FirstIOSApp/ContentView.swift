import SwiftUI

struct ContentView: View {
    @State private var inputValue = ""
    @State private var selectedCategory = UnitCategory.length
    @State private var fromUnit = "Meter"
    @State private var toUnit = "Fuß"
    @State private var showingResult = false
    @State private var showingFavorites = false
    @State private var showingAddFavorite = false
    @State private var showingHistory = false
    
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var historyManager = HistoryManager.shared
    
    // Computed property für das Ergebnis
    private var convertedValue: String {
        guard let value = Double(inputValue) else { return "0" }
        
        if let result = UnitConverter.convert(value: value,
                                             from: fromUnit,
                                             to: toUnit,
                                             category: selectedCategory) {
            return String(format: "%.2f", result)
        } else {
            return "0"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    categorySelectionView
                    inputCardView
                    swapButtonView
                    outputCardView
                    actionButtonsView
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Einheiten-Umrechner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingFavorites = true
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Favoriten")
                        }
                        .foregroundColor(.primaryBlue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Stern getippt! InputValue: \(inputValue)")
                        if !inputValue.isEmpty {
                            showingAddFavorite = true
                        } else {
                            // Toggle Favorit auch ohne Eingabe möglich
                            let favoriteName = "\(fromUnit) → \(toUnit)"
                            favoritesManager.toggleFavorite(
                                category: selectedCategory,
                                fromUnit: fromUnit,
                                toUnit: toUnit,
                                name: favoriteName
                            )
                        }
                    }) {
                        Image(systemName: favoritesManager.isFavorite(
                            category: selectedCategory,
                            fromUnit: fromUnit,
                            toUnit: toUnit
                        ) ? "star.fill" : "star")
                        .foregroundColor(.primaryBlue)
                        .scaleEffect(1.2) // Größer für bessere Touch-Targets
                    }
                    .buttonStyle(PlainButtonStyle()) // Verhindert Standard-Button-Styling
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                          to: nil, from: nil, for: nil)
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView(isPresented: $showingFavorites) { favorite in
                // Lade den ausgewählten Favoriten
                if let category = favorite.unitCategory {
                    selectedCategory = category
                    fromUnit = favorite.fromUnit
                    toUnit = favorite.toUnit
                    inputValue = ""
                    showingResult = false
                }
            }
        }
        .alert("Favorit hinzufügen", isPresented: $showingAddFavorite) {
            TextField("Name", text: .constant("\(fromUnit) → \(toUnit)"))
                .disabled(true)
            
            Button("Hinzufügen") {
                let favoriteName = "\(fromUnit) → \(toUnit)"
                favoritesManager.toggleFavorite(
                    category: selectedCategory,
                    fromUnit: fromUnit,
                    toUnit: toUnit,
                    name: favoriteName
                )
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Diese Umrechnung als Favorit speichern")
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(isPresented: $showingHistory) { entry in
                // Lade den ausgewählten Verlaufseintrag
                if let category = UnitCategory.allCases.first(where: { $0.rawValue == entry.category }) {
                    selectedCategory = category
                    fromUnit = entry.fromUnit
                    toUnit = entry.toUnit
                    inputValue = entry.formattedValue
                    showingResult = true
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kategorie")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(UnitCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.spring()) {
                                selectedCategory = category
                                fromUnit = category.units.first ?? ""
                                toUnit = category.units.last ?? ""
                                showingResult = false
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var inputCardView: some View {
        CardView {
            VStack(alignment: .leading, spacing: 15) {
                Label("Von", systemImage: "arrow.up.circle.fill")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
                
                HStack(spacing: 15) {
                    TextField("0", text: $inputValue)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .onChange(of: inputValue) {
                            showingResult = !inputValue.isEmpty
                        }
                    
                    Menu {
                        ForEach(selectedCategory.units, id: \.self) { unit in
                            Button(unit) {
                                fromUnit = unit
                            }
                        }
                    } label: {
                        HStack {
                            Text(fromUnit)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var swapButtonView: some View {
        Button(action: {
            withAnimation(.spring()) {
                let temp = fromUnit
                fromUnit = toUnit
                toUnit = temp
            }
        }) {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.primaryBlue)
                .background(Circle().fill(Color.white).frame(width: 50, height: 50))
                .shadow(color: .primaryBlue.opacity(0.3), radius: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var outputCardView: some View {
        CardView {
            VStack(alignment: .leading, spacing: 15) {
                Label("Nach", systemImage: "arrow.down.circle.fill")
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
                
                if showingResult {
                    ResultDisplayView(value: convertedValue, unit: toUnit)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    ResultDisplayView(value: "Ergebnis", unit: toUnit)
                        .opacity(0.5)
                }
                
                Menu {
                    ForEach(selectedCategory.units, id: \.self) { unit in
                        Button(unit) {
                            toUnit = unit
                        }
                    }
                } label: {
                    HStack {
                        Text("Einheit: \(toUnit)")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 20) {
            ActionButton(
                title: "Verlauf",
                icon: "clock.arrow.circlepath",
                color: .blue
            ) {
                showingHistory = true
            }
            
            ActionButton(
                title: "Löschen",
                icon: "trash",
                color: .red
            ) {
                inputValue = ""
                showingResult = false
            }
            .disabled(inputValue.isEmpty)
            
            ActionButton(
                title: "Kopieren",
                icon: "doc.on.doc",
                color: .green
            ) {
                UIPasteboard.general.string = "\(convertedValue) \(toUnit)"
                
                // Speichere im Verlauf beim Kopieren
                if let value = Double(inputValue),
                   let result = Double(convertedValue) {
                    historyManager.addEntry(
                        value: value,
                        result: result,
                        fromUnit: fromUnit,
                        toUnit: toUnit,
                        category: selectedCategory
                    )
                }
            }
            .disabled(inputValue.isEmpty)
        }
        .padding(.horizontal)
    }
}

// Category Button Component
struct CategoryButton: View {
    let category: UnitCategory
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch category {
        case .length: return "ruler"
        case .weight: return "scalemass"
        case .temperature: return "thermometer"
        case .currency: return "dollarsign.circle"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.primaryBlue : Color(UIColor.tertiarySystemBackground))
            .cornerRadius(15)
            .shadow(color: isSelected ? .primaryBlue.opacity(0.3) : .clear, radius: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Action Button Component
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(25)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ContentView()
}
