//  SearchBarView.swift
//  ReSouq
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Search Resouq...", text: $searchText)
                .padding(10)
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .font(.custom("ReemKufi-regular", size: 14))

            Button(action: {
                if !searchText.isEmpty {
                    onSearch()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.trailing, 5)
            }
        }
        .padding(.vertical, 5)
        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
    }
}
