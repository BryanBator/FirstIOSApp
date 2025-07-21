//
//  ContentView.swift
//  FirstIOSApp
//
//  Created by Bryan Bator on 21.07.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Meine erste iOS App!")
                .font(.title)
        }
        .padding()
    }
}
#Preview {
    ContentView()
}
