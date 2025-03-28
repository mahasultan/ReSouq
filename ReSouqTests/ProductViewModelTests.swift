import XCTest
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
@testable import ReSouq

class ProductViewModelTests: XCTestCase {
    var productViewModel: ProductViewModel!
    var mockProduct: Product!
    var mockCart: Cart!

    override func setUp() {
        super.setUp()

        productViewModel = ProductViewModel()

        mockProduct = Product(
            id: "test-product-123",
            name: "Mock Product",
            price: 100.0,
            description: "This is a mock product",
            imageUrls: [],  // ✅ FIXED: must be [String]
            sellerID: "test-seller",
            categoryID: "test-category",
            gender: "Unisex",
            condition: "New"
        )

        mockCart = Cart(userID: "test-user")
        mockCart.products.append(CartItem(id: UUID().uuidString, product: mockProduct)) // ✅ No quantity
    }

    override func tearDown() {
        productViewModel = nil
        mockProduct = nil
        mockCart = nil
        super.tearDown()
    }

    func testFetchProducts() {
        let expectation = XCTestExpectation(description: "Fetch products successfully")

        productViewModel.fetchProducts()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.productViewModel.products, "Products should not be nil after fetching")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetProductsByCategory() {
        let categoryID = "test-category"
        let categories = [Category(id: "test-category", name: "Test Category", parentCategoryID: nil)]

        productViewModel.products = [mockProduct]

        let filteredProducts = productViewModel.getProducts(categoryID: categoryID, categories: categories)

        XCTAssertEqual(filteredProducts.count, 1, "Should return one product matching the category")
        XCTAssertEqual(filteredProducts.first?.name, "Mock Product", "Filtered product should match")
    }

    func testGetProductsBySearchQuery() {
        let searchQuery = "Mock"
        let categories: [ReSouq.Category] = []

        productViewModel.products = [mockProduct]

        let searchResults = productViewModel.getProducts(searchQuery: searchQuery, categories: categories)

        XCTAssertEqual(searchResults.count, 1, "Search should return one matching product")
        XCTAssertEqual(searchResults.first?.name, "Mock Product", "Search result should match")
    }


    
}
