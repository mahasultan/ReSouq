//
//  CategoryProductsViewTests.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 16/03/2025.
//


import XCTest
import SwiftUI
@testable import ReSouq

class CategoryProductsViewTests: XCTestCase {
    var productVM: ProductViewModel!
    var categoryVM: CategoryViewModel!

    override func setUp() {
        super.setUp()
        productVM = ProductViewModel()
        categoryVM = CategoryViewModel()
    }

    override func tearDown() {
        productVM = nil
        categoryVM = nil
        super.tearDown()
    }

    // Test: Fetching and Filtering Products
    func testFilteredProducts() {
        let categoryID = "category123"
        
        let product1 = Product(
            id: "1",
            name: "Test Product 1",
            price: 100.0,
            description: "A test product",
            imageURL: "https://example.com/image1.jpg",
            sellerID: "seller123",
            categoryID: categoryID, // Matches category
            gender: "Unisex",
            condition: "New",
            createdAt: Date()
        )

        let product2 = Product(
            id: "2",
            name: "Test Product 2",
            price: 150.0,
            description: "Another test product",
            imageURL: "https://example.com/image2.jpg",
            sellerID: "seller456",
            categoryID: "differentCategory", // Different category
            gender: "Unisex",
            condition: "Used",
            createdAt: Date()
        )

        // Add mock products to ViewModel
        productVM.products = [product1, product2]

        // Filter products by category
        let filteredProducts = productVM.getProducts(categoryID: categoryID, categories: categoryVM.categories)

        // Expected only 1 product to match the category
        XCTAssertEqual(filteredProducts.count, 1, "Only one product should match the selected category")
        XCTAssertEqual(filteredProducts.first?.name, "Test Product 1", "Filtered product should be 'Test Product 1'")
    }

    // Test: Display "No Products Found"
    func testNoProductsMessage() {
        let categoryID = "emptyCategory"

        // No products in ViewModel
        productVM.products = []

        let filteredProducts = productVM.getProducts(categoryID: categoryID, categories: categoryVM.categories)

        // Expected no products to be found
        XCTAssertTrue(filteredProducts.isEmpty, "Filtered products should be empty for a non-existing category")
    }
}
