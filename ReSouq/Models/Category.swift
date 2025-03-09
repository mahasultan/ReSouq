//
//  Category.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 08/03/2025.
//


import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let parentCategoryID: String? // If it's a subcategory, else nil
}
