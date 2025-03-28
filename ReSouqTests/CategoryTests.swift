//
//  CategoryTests.swift
//  ReSouq
//
//


import XCTest
@testable import ReSouq

class CategoryTests: XCTestCase {
    
    func testCategoryInitialization() {
        let category = Category(id: "1", name: "Clothing", parentCategoryID: nil)
        XCTAssertEqual(category.id, "1", "Category ID should be 1")
        XCTAssertEqual(category.name, "Clothing", "Category name should be 'Clothing'")
        XCTAssertNil(category.parentCategoryID, "ParentCategoryID should be nil for main category")
    }
    
    func testPredefinedCategoriesCount() {
        XCTAssertEqual(PredefinedCategories.categories.count, 32, "There should be exactly 32 predefined categories")
    }
    
    func testParentCategoryAssignment() {
        if let subcategory = PredefinedCategories.categories.first(where: { $0.id == "2" }) {
            XCTAssertEqual(subcategory.parentCategoryID, "1", "T-Shirts should have Clothing as parent category")
        } else {
            XCTFail("T-Shirts category not found in predefined categories")
        }
    }
    
    func testMainCategoriesExist() {
        let mainCategories = ["Clothing", "Shoes", "Accessories"]
        for categoryName in mainCategories {
            XCTAssertTrue(PredefinedCategories.categories.contains { $0.name == categoryName && $0.parentCategoryID == nil }, "\(categoryName) should be a main category")
        }
    }
    
    func testSubcategoriesExist() {
        let subcategoryPairs = [
            ("Sneakers", "Shoes"),
            ("Bags", "Accessories"),
            ("Dresses", "Clothing")
        ]
        
        for (subcategory, parent) in subcategoryPairs {
            let subcategoryObj = PredefinedCategories.categories.first { $0.name == subcategory }
            let parentObj = PredefinedCategories.categories.first { $0.name == parent }
            
            XCTAssertNotNil(subcategoryObj, "\(subcategory) should exist in predefined categories")
            XCTAssertNotNil(parentObj, "\(parent) should exist in predefined categories")
            XCTAssertEqual(subcategoryObj?.parentCategoryID, parentObj?.id, "\(subcategory) should be under \(parent)")
        }
    }
}
