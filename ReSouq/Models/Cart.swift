//
//  Cart.swift
//  ReSouq

import Foundation
import FirebaseFirestore

struct Cart: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String 
    var products: [CartItem] = []
    
    var totalPrice: Double {
        return products.reduce(0) { $0 + $1.product.price }
    }
}

struct CartItem: Identifiable, Codable {
    var id: String
    var product: Product

}


