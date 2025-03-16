//
//  UserTests.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 16/03/2025.
//


import XCTest
@testable import ReSouq

class UserTests: XCTestCase {
    
    func testUserInitialization() {
        let user = User(
            id: nil, // `id` is nil to avoid Firestore error
            fullName: "John Doe",
            email: "john@example.com",
            phoneNumber: "+97412345678",
            profileImageURL: "https://example.com/image.jpg",
            location: "Doha"
        )
        
        XCTAssertNotNil(user, "User object should be created successfully")
        XCTAssertNil(user.id, "User ID should be nil since Firestore manages it")
        XCTAssertEqual(user.fullName, "John Doe", "Full name should be correctly assigned")
        XCTAssertEqual(user.email, "john@example.com", "Email should be correctly assigned")
        XCTAssertEqual(user.phoneNumber, "+97412345678", "Phone number should be correctly assigned")
        XCTAssertEqual(user.profileImageURL, "https://example.com/image.jpg", "Profile image URL should be correctly assigned")
        XCTAssertEqual(user.location, "Doha", "Location should be correctly assigned")
    }
    
    func testUserDefaultCreatedAt() {
        let user = User(
            id: nil,
            fullName: "Jane Doe",
            email: "jane@example.com"
        )

        XCTAssertNotNil(user.createdAt, "CreatedAt should not be nil")
        XCTAssertTrue(user.createdAt.timeIntervalSinceNow < 1, "CreatedAt should be set to the current time")
    }
    
}
