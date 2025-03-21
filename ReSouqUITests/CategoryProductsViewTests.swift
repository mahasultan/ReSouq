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
    var productViewModel: ProductViewModel!
    var categoryViewModel: CategoryViewModel!

    override func setUp() {
        super.setUp()
        productViewModel = ProductViewModel()
        categoryViewModel = CategoryViewModel()
    }

    override func tearDown() {
        productViewModel = nil
        categoryViewModel = nil
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
            imageURL: ["https://example.com/image1.jpg"],
            sellerID: "seller123",
            categoryID: categoryID, // Matches category
            gender: "Unisex",
            condition: "New"
            
        )

        let product2 = Product(
            id: "2",
            name: "Test Product 2",
            price: 150.0,
            description: "Another test product",
            imageURL: ["https://example.com/image2.jpg"],
            sellerID: "seller456",
            categoryID: "differentCategory", // Different category
            gender: "Unisex",
            condition: "Used"
            
        )

        // Add mock products to ViewModel
        productViewModel.products = [product1, product2]

        // Filter products by category
        let filteredProducts = productViewModel.getProducts(categoryID: categoryID, categories: categoryViewModel.categories)

        // Expected only 1 product to match the category
        XCTAssertEqual(filteredProducts.count, 1, "Only one product should match the selected category")
        XCTAssertEqual(filteredProducts.first?.name, "Test Product 1", "Filtered product should be 'Test Product 1'")
    }

    // Test: Display "No Products Found"
    func testNoProductsMessage() {
        let categoryID = "emptyCategory"

        // No products in ViewModel
        productViewModel.products = []

        let filteredProducts = productViewModel.getProducts(categoryID: categoryID, categories: categoryViewModel.categories)

        // Expected no products to be found
        XCTAssertTrue(filteredProducts.isEmpty, "Filtered products should be empty for a non-existing category")
    }
}
