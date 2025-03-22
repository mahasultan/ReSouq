//
//  Product.swift
//  ReSouq
//
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var productID: String?
    var name: String
    var price: Double
    var description: String
    var imageUrls: [String] 
    var sellerID: String
    var size: String?
    var categoryID: String
    var gender: String
    var condition: String
    var createdAt: Date = Date()
    var isSold: Bool?
    
    
    init(
            id: String? = nil,
            productID: String? = nil,
            name: String,
            price: Double,
            description: String,
            imageUrls: [String],
            sellerID: String,
            categoryID: String,
            gender: String,
            condition: String,
            size: String? = nil,
            isSold: Bool? = false
        ) {
            self.id = id
            self.productID = productID
            self.name = name
            self.price = price
            self.description = description
            self.imageUrls = imageUrls
            self.sellerID = sellerID
            self.categoryID = categoryID
            self.gender = gender
            self.condition = condition
            self.size = size
            self.isSold = isSold
        }
    }


