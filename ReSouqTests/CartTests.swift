//
//  CartTests.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 16/03/2025.
//

import XCTest
@testable import ReSouq

class CartTests: XCTestCase {
    
    func testCartInitialization() {
        let cart = Cart(userID: "testUser123")
        
        XCTAssertNotNil(cart, "Cart should be initialized")
        XCTAssertEqual(cart.userID, "testUser123", "Cart userID should be correctly assigned")
        XCTAssertTrue(cart.products.isEmpty, "Cart should be empty initially")
    }

    func testCartItemInitialization() {
        let product = Product(
            id: "prod123",
            name: "Test Product",
            price: 50.0,
            description: "Sample product",
            imageUrls: [],
            sellerID: "seller123",
            categoryID: "cat123",
            gender: "Unisex",
            condition: "New"
        )

        let cartItem = CartItem(id: UUID().uuidString, product: product)

        XCTAssertNotNil(cartItem, "CartItem should be initialized")
        XCTAssertNotNil(cartItem.id, "CartItem should have an ID")
        XCTAssertEqual(cartItem.product.name, "Test Product", "CartItem should store the correct product")
    }

    func testTotalPriceCalculation() {
        let product1 = Product(
            id: "prod1",
            name: "Product 1",
            price: 20.0,
            description: "First product",
            imageUrls: [],
            sellerID: "seller123",
            categoryID: "cat123",
            gender: "Unisex",
            condition: "New"
        )

        let product2 = Product(
            id: "prod2",
            name: "Product 2",
            price: 30.0,
            description: "Second product",
            imageUrls: [],
            sellerID: "seller456",
            categoryID: "cat456",
            gender: "Unisex",
            condition: "Used"
        )

        var cart = Cart(userID: "testUser123")
        
        let cartItem1 = CartItem(id: UUID().uuidString, product: product1)
        let cartItem2 = CartItem(id: UUID().uuidString, product: product2)

        cart.products.append(cartItem1)
        cart.products.append(cartItem2)

        let totalPrice = cart.totalPrice
        
        XCTAssertEqual(totalPrice, 50.0, "Total price should be correctly calculated (20 + 30)")
    }

    func testEmptyCartTotalPrice() {
        let cart = Cart(userID: "testUser123")
        XCTAssertEqual(cart.totalPrice, 0.0, "Total price should be 0 for an empty cart")
    }
}
