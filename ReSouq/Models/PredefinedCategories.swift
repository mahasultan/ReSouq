//
//  PredefinedCategories.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 08/03/2025.
//

import Foundation

struct PredefinedCategories {
    static let categories: [Category] = [
        // Clothing (Main Category)
        Category(id: "1", name: "Clothing", parentCategoryID: nil),
        Category(id: "2", name: "T-Shirts", parentCategoryID: "1"),
        Category(id: "3", name: "Shirts", parentCategoryID: "1"),
        Category(id: "4", name: "Dresses", parentCategoryID: "1"),
        Category(id: "5", name: "Sweatshirts", parentCategoryID: "1"),
        Category(id: "6", name: "Trousers", parentCategoryID: "1"),
        Category(id: "7", name: "Jeans", parentCategoryID: "1"),
        Category(id: "8", name: "Shorts", parentCategoryID: "1"),
        Category(id: "9", name: "Skirts", parentCategoryID: "1"),
        Category(id: "10", name: "Jackets", parentCategoryID: "1"),
        Category(id: "11", name: "Coats", parentCategoryID: "1"),
        Category(id: "12", name: "Suits", parentCategoryID: "1"),
        Category(id: "13", name: "Sportswear", parentCategoryID: "1"),

        // Shoes (Main Category)
        Category(id: "14", name: "Shoes", parentCategoryID: nil),
        Category(id: "15", name: "Sneakers", parentCategoryID: "14"),
        Category(id: "16", name: "Sandals", parentCategoryID: "14"),
        Category(id: "17", name: "Pumps", parentCategoryID: "14"),
        Category(id: "18", name: "Boots", parentCategoryID: "14"),
        Category(id: "19", name: "Ballerinas", parentCategoryID: "14"),
        Category(id: "20", name: "Loafers", parentCategoryID: "14"),
        Category(id: "21", name: "Formal Shoes", parentCategoryID: "14"),
        Category(id: "22", name: "Running Shoes", parentCategoryID: "14"),

        // Accessories (Main Category)
        Category(id: "23", name: "Accessories", parentCategoryID: nil),
        Category(id: "24", name: "Bags", parentCategoryID: "23"),
        Category(id: "25", name: "Sunglasses", parentCategoryID: "23"),
        Category(id: "26", name: "Watches", parentCategoryID: "23"),
        Category(id: "27", name: "Belts", parentCategoryID: "23"),
        Category(id: "28", name: "Wallets", parentCategoryID: "23"),
        Category(id: "29", name: "Hats & Caps", parentCategoryID: "23"),
        Category(id: "30", name: "Scarves", parentCategoryID: "23"),
        Category(id: "31", name: "Gloves", parentCategoryID: "23"),
        Category(id: "32", name: "Jewelry", parentCategoryID: "23"),
    ]
}
