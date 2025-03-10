//
//  CategoryBox.swift
//  ReSouq
//


import SwiftUI

struct CategoryBox: View {
    var category: Category

    var body: some View {
        VStack {
            Image(systemName: "bag.fill") // Placeholder for category images
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text(category.name)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
