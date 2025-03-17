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
    var shippingAddress: String?


    init(userID: String, products: [CartItem], totalPrice: Double, shippingAddress: String?) {
        self.userID = userID
        self.products = products
        self.totalPrice = totalPrice
        self.shippingAddress = shippingAddress
        self.orderDate = Date()
    }
}
