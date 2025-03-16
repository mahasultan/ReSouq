import XCTest
import SwiftUI
import ViewInspector
@testable import ReSouq  // Ensure this imports your project

final class BottomBarViewTests: XCTestCase {
    var navigationManager: NavigationManager!
    var cartViewModel: CartViewModel!
    var bottomBarView: AnyView!

    override func setUp() {
        super.setUp()
        navigationManager = NavigationManager()
        cartViewModel = CartViewModel()

        bottomBarView = AnyView(
            BottomBarView()
                .environmentObject(navigationManager)
                .environmentObject(cartViewModel)
        )
    }

    override func tearDown() {
        navigationManager = nil
        cartViewModel = nil
        bottomBarView = nil
        super.tearDown()
    }

    func testBottomBarView_Exists() {
        XCTAssertNotNil(bottomBarView, "BottomBarView should not be nil")
    }

    func testBottomBarView_HasExpectedButtons() {
        let view = BottomBarView()
            .environmentObject(navigationManager)
            .environmentObject(cartViewModel)

        XCTAssertNoThrow(try {
            let inspector = try view.inspect()

            XCTAssertNotNil(try inspector.find(button: "Home"))
            XCTAssertNotNil(try inspector.find(button: "Likes"))
            XCTAssertNotNil(try inspector.find(button: "Cart"))
        }(), "Buttons should exist in BottomBarView")
    }

    func testBottomBarView_NavigationChangesPage() {
        let view = BottomBarView()
            .environmentObject(navigationManager)
            .environmentObject(cartViewModel)

        XCTAssertNoThrow(try {
            let inspector = try view.inspect()

            // ✅ Tap "Home" button
            try inspector.find(button: "Home").tap()
            XCTAssertEqual(navigationManager.currentPage, "Home")

            // ✅ Tap "Likes" button
            try inspector.find(button: "Likes").tap()
            XCTAssertEqual(navigationManager.currentPage, "Likes")
        }(), "Navigation should change pages")
    }
}
