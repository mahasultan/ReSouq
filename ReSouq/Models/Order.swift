//
//  Order.swift
//  ReSouq
//

import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var products: [CartItem] // Previous cart items
    var totalPrice: Double
    var orderDate: Date

    init(userID: String, products: [CartItem], totalPrice: Double) {
        self.userID = userID
        self.products = products
        self.totalPrice = totalPrice
        self.orderDate = Date()
    }
}
