//  SearchBarView.swift
//  ReSouq
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            TextField("Search Resouq...", text: $searchText)
                .padding(10)
                .background(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .font(.custom("ReemKufi-Bold", size: 18))
                .padding(.horizontal)

            Button(action: {
                if !searchText.isEmpty {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
        .padding(.vertical, 5)
        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))) // Beige Background
    }
}
