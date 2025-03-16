//
//  ContentViewTests.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 16/03/2025.
//
import XCTest
import SwiftUI
import ViewInspector
@testable import ReSouq

// Enable View Inspection for ContentView
extension ContentView: Inspectable {}

final class ContentViewTests: XCTestCase {

    func testContentView_DisplaysCorrectly() throws {
        // Given: Create the View
        let view = ContentView()

        // When: Host the view in ViewInspector
        ViewHosting.host(view: view)

        // Then: Check if the "Hello, world!" text exists
        XCTAssertNoThrow(try view.inspect().find(text: "Hello, world!"))

        // Check if the image exists
        XCTAssertNoThrow(try view.inspect().find(ViewType.Image.self))
    }
}

