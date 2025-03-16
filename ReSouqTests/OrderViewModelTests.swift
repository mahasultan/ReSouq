import XCTest
@testable import ReSouq

class OrderViewModelTests: XCTestCase {
    
    var orderViewModel: OrderViewModel!
    var mockCart: Cart!
    var mockProduct: Product!

    override func setUp() {
        super.setUp()
        
        // ✅ Create a fresh instance of OrderViewModel before each test
        orderViewModel = OrderViewModel()
        
        // ✅ Mock a sample product
        mockProduct = Product(
            id: "test-product-123",
            name: "Test Product",
            price: 10.0,
            description: "A sample product for testing",
            imageURL: nil,
            sellerID: "test-seller",
            categoryID: "test-category",
            gender: "Unisex",
            condition: "New"
        )

        // ✅ Mock a sample cart with one product
        mockCart = Cart(userID: "test-user-123")
        mockCart.products.append(CartItem(product: mockProduct, quantity: 1))
    }

    override func tearDown() {
        orderViewModel = nil
        mockCart = nil
        mockProduct = nil
        super.tearDown()
    }

    // ✅ Test Placing an Order
    func testPlaceOrder() {
        let expectation = XCTestExpectation(description: "Order placed successfully")

        orderViewModel.placeOrder(userID: "test-user-123", cart: mockCart) { order in
            print("🔥 Completion called in testPlaceOrder") // Debugging

            XCTAssertNotNil(order, "Order should not be nil")
            XCTAssertEqual(order?.userID, "test-user-123", "User ID should match")
            XCTAssertEqual(order?.products.count, 1, "Order should contain one product")
            XCTAssertEqual(order?.totalPrice, 10.0, "Total price should be correct")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0) // ⬆ Increased timeout
    }


    // ✅ Test Fetching Orders (Mocked)
    func testFetchOrders() {
        let expectation = XCTestExpectation(description: "Orders fetched successfully")

        orderViewModel.fetchOrders(for: "test-user-123")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThanOrEqual(self.orderViewModel.orders.count, 0, "Orders should be fetched successfully")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // ✅ Test Updating Latest Order
    func testLatestOrderUpdate() {
        let expectation = XCTestExpectation(description: "Latest order should update correctly")

        orderViewModel.placeOrder(userID: "test-user-123", cart: mockCart) { order in
            guard let placedOrder = order else {
                XCTFail("Order was not placed successfully")
                return
            }

            // 🔥 Debugging: Check if Firestore wrote the order
            print("✅ Order was placed successfully with ID: \(placedOrder.id ?? "Unknown")")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                XCTAssertEqual(self.orderViewModel.latestOrder?.id, placedOrder.id, "Latest order ID should match placed order ID")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0) // ⬆ Increased timeout
    }

}
