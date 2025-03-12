//
//  CategoryBox.swift
//  ReSouq
//

import SwiftUI

struct CategoryBox: View {
    var category: Category?
    var isSeeAll: Bool = false

    private var categoryImage: String {
        guard let category = category else { return "ellipsis.circle.fill" }
        switch category.name.lowercased() {
        case "clothing": return "tshirt.fill"
        case "shoes": return "shoe.fill"
        case "accessories": return "sunglasses.fill"
        default: return "bag.fill"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: categoryImage)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) 
            Text(isSeeAll ? "See All" : category?.name ?? "Unknown")
                .font(.custom("ReemKufi-Bold", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))) // Beige Background
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
