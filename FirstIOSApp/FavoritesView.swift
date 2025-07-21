//
//  FavoritesView.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @Binding var isPresented: Bool
    
    // Callback wenn ein Favorit ausgewählt wird
    var onSelect: ((Favorite) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if favoritesManager.favorites.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Keine Favoriten")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Füge häufig verwendete Umrechnungen als Favoriten hinzu")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Favoriten Liste
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(favoritesManager.favorites) { favorite in
                                FavoriteRow(favorite: favorite) {
                                    // Favorit ausgewählt
                                    onSelect?(favorite)
                                    isPresented = false
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favoriten")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        isPresented = false
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
}

// Einzelne Favoriten-Zeile
struct FavoriteRow: View {
    let favorite: Favorite
    let onTap: () -> Void
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var showDeleteConfirmation = false
    
    var icon: String {
        switch favorite.unitCategory {
        case .length: return "ruler"
        case .weight: return "scalemass"
        case .temperature: return "thermometer"
        case .currency: return "dollarsign.circle"
        case .none: return "questionmark.circle"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            CardView {
                HStack(spacing: 15) {
                    // Icon
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                    
                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favorite.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("\(favorite.fromUnit) → \(favorite.toUnit)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(favorite.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primaryBlue.opacity(0.1))
                                .foregroundColor(.primaryBlue)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    // Delete Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog(
            "Favorit löschen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                withAnimation {
                    favoritesManager.removeFavorite(favorite)
                }
            }
        } message: {
            Text("'\(favorite.name)' wird aus den Favoriten entfernt.")
        }
    }
}

// Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(isPresented: .constant(true))
    }
}
