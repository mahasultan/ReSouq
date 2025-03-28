//
//  AuthViewModelTests.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 16/03/2025.
//


import XCTest
@testable import ReSouq

class AuthViewModelTests: XCTestCase {
    var authViewModel: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        authViewModel = AuthViewModel()
    }
    
    func testSignUpWithValidData() {
        let expectation = self.expectation(description: "User should sign up successfully")
        
        authViewModel.signUp(fullName: "Test User", email: "tsting14613@exaple.com", password: "password1223", phoneNumber: "01308765", profileImage: nil) { error in
            XCTAssertNil(error, "There should be no error for valid signup")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
