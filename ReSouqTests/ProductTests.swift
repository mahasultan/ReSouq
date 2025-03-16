import XCTest
import FirebaseFirestore


@testable import ReSouq

class ProductTests: XCTestCase {
    
    func testProductEncodingAndDecoding() throws {
        let product = Product(
            id: "123",
            name: "Test Product",
            price: 99.99,
            description: "A sample test product",
            imageURL: "https://example.com/image.jpg",
            sellerID: "seller123",
            categoryID: "cat123",
            gender: "Unisex",
            condition: "New",
            createdAt: Date()
        )

        // MARK: - Encoding
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(product)
        
        XCTAssertNotNil(data, "Encoding should produce valid JSON data")

        // Ensure the id is not present in the encoded data
        let encodedDictionary = data as? [String: Any]
        XCTAssertNil(encodedDictionary?["id"], "ID should not be encoded in Firestore")

        // MARK: - Decoding
        let decoder = Firestore.Decoder()
        let decodedProduct = try decoder.decode(Product.self, from: data)

        XCTAssertEqual(decodedProduct.name, product.name)
        XCTAssertEqual(decodedProduct.price, product.price)
        XCTAssertEqual(decodedProduct.description, product.description)
        XCTAssertEqual(decodedProduct.sellerID, product.sellerID)
        XCTAssertEqual(decodedProduct.categoryID, product.categoryID)
        XCTAssertEqual(decodedProduct.gender, product.gender)
        XCTAssertEqual(decodedProduct.condition, product.condition)
    }
}
