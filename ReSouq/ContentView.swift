//
//  ContentView.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 13/02/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel()) 
}
