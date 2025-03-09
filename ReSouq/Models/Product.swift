//
//  Product.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 04/03/2025.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
    var description: String
    var imageURL: String?
    var sellerID: String
    var categoryID: String
    var createdAt: Date = Date()
}
