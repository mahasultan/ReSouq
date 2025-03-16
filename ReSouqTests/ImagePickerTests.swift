//
//  ImagePickerTests.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 16/03/2025.
//
import XCTest
import SwiftUI
@testable import ReSouq

final class ImagePickerTests: XCTestCase {
    func testImagePicker_CoordinatorHandlesImageSelection() {
        // Arrange: Create a Binding for selectedImage
        var selectedImage: UIImage? = nil
        let binding = Binding<UIImage?>(
            get: { selectedImage },
            set: { selectedImage = $0 }
        )

        let imagePicker = ImagePicker(selectedImage: binding)
        let coordinator = ImagePicker.Coordinator(imagePicker)

        // Act: Simulate selecting an image
        let testImage = UIImage(systemName: "photo")!  // Mock UIImage
        let info: [UIImagePickerController.InfoKey: Any] = [.originalImage: testImage]
        coordinator.imagePickerController(UIImagePickerController(), didFinishPickingMediaWithInfo: info)

        // Assert: Check if selectedImage was set correctly
        XCTAssertNotNil(selectedImage, "Selected image should not be nil after picking an image")
        XCTAssertEqual(selectedImage, testImage, "Selected image should be the same as the picked image")
    }
}

