
//
//  User.swift
//  ReSouq
//
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var phoneNumber: String?
    var profileImageURL: String?
    var location: String?
    var createdAt: Date = Date()
}

