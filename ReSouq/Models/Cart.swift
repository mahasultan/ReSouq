//
//  Cart.swift
//  ReSouq

import Foundation
import FirebaseFirestore

struct Cart: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String // Associate the cart with a specific user
    var products: [CartItem] = [] // List of products in the cart
    
    var totalPrice: Double {
        return products.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
}

struct CartItem: Identifiable, Codable {
    var id: String
    var product: Product
    var quantity: Int

    init(product: Product, quantity: Int) {
        self.id = "\(product.id ?? UUID().uuidString)_\(UUID().uuidString)"
        self.product = product
        self.quantity = quantity
    }
}

