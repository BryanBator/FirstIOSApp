//
//  CurrencyStatusView.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

struct CurrencyStatusView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        VStack(spacing: 10) {
            if currencyManager.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Lade aktuelle Kurse...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(20)
            } else if let error = currencyManager.errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Offline-Modus")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Nutze gespeicherte Kurse")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            } else if currencyManager.ratesAreOutdated {
                Button(action: {
                    currencyManager.fetchExchangeRates()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kurse veraltet")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("Tippen zum Aktualisieren")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Kurse aktuell")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("Stand: \(currencyManager.formattedLastUpdate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .animation(.easeInOut, value: currencyManager.isLoading)
        .animation(.easeInOut, value: currencyManager.errorMessage)
    }
}
