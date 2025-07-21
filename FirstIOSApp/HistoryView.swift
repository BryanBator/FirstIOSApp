//
//  HistoryView.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared
    @Binding var isPresented: Bool
    @State private var showingClearConfirmation = false
    
    // Callback wenn ein Verlaufseintrag ausgewählt wird
    var onSelect: ((HistoryEntry) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if historyManager.entries.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Kein Verlauf")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Deine Umrechnungen werden hier gespeichert")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Verlauf Liste
                    List {
                        ForEach(historyManager.groupedEntries(), id: \.key) { date, entries in
                            Section(header: Text(date)) {
                                ForEach(entries) { entry in
                                    HistoryRow(entry: entry) {
                                        onSelect?(entry)
                                        isPresented = false
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        historyManager.deleteEntry(entries[index])
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Verlauf")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !historyManager.entries.isEmpty {
                        Button("Löschen") {
                            showingClearConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        isPresented = false
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
            .confirmationDialog(
                "Verlauf löschen?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Alles löschen", role: .destructive) {
                    withAnimation {
                        historyManager.clearHistory()
                    }
                }
            } message: {
                Text("Der gesamte Verlauf wird gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
}

// Einzelne Verlaufszeile
struct HistoryRow: View {
    let entry: HistoryEntry
    let onTap: () -> Void
    
    var icon: String {
        if let category = UnitCategory.allCases.first(where: { $0.rawValue == entry.category }) {
            switch category {
            case .length: return "ruler"
            case .weight: return "scalemass"
            case .temperature: return "thermometer"
            case .currency: return "dollarsign.circle"
            }
        }
        return "questionmark.circle"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.primaryBlue)
                    .cornerRadius(10)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.summary)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Pfeil
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(isPresented: .constant(true))
    }
}
