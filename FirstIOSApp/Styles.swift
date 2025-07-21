//
//  Styles.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

// Custom Colors
extension Color {
    static let primaryBlue = Color(red: 0.2, green: 0.4, blue: 0.9)
    static let lightBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
}

// Custom Card View
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .font(.system(size: 18, weight: .medium))
    }
}

// Animated Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Result Display View
struct ResultDisplayView: View {
    let value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(unit)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
