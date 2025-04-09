//
//  SellerRating.swift
//  ReSouq
//
//

import Foundation
import FirebaseFirestore

struct SellerRating: Identifiable, Codable {
    @DocumentID var id: String?
    var orderID: String
    var sellerID: String
    var buyerID: String
    var rating: Int
    var reviewText: String?
    var timestamp: Date = Date()
}
