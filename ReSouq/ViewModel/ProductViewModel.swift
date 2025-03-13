//
//  ProductViewModel.swift
//  ReSouq
//
//


import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import FirebaseAuth


class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var likedProducts: [Product] = []
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let userID = Auth.auth().currentUser?.uid

    // Fetch products from Firestore
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            DispatchQueue.main.async {
                self.products = documents.compactMap { try? $0.data(as: Product.self) }
            }
        }
    }
    
    
    func getProducts(categoryID: String? = nil, searchQuery: String? = nil, categories: [Category]) -> [Product] {
        var filteredProducts = products

        // If filtering by category (e.g., Clothing + subcategories)
        if let categoryID = categoryID {
            let subcategoryIDs = categories
                .filter { $0.parentCategoryID == categoryID }
                .map { $0.id }
            
            filteredProducts = filteredProducts.filter { product in
                product.categoryID == categoryID || subcategoryIDs.contains(product.categoryID)
            }
        }

        // If filtering by search query
        if let query = searchQuery, !query.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                let categoryName = categories.first(where: { $0.id == product.categoryID })?.name ?? ""
                return product.name.localizedCaseInsensitiveContains(query) ||
                       product.gender.localizedCaseInsensitiveContains(query) ||
                       product.condition.localizedCaseInsensitiveContains(query) ||
                product.description.localizedCaseInsensitiveContains(query) ||
                       categoryName.localizedCaseInsensitiveContains(query)
            }
        }

        return filteredProducts
    }

    
    
    // Fetch liked products from Firestore
    func fetchLikedProducts() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("likes").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            DispatchQueue.main.async {
                self.likedProducts = documents.compactMap { try? $0.data(as: Product.self) }
            }
        }
    }

    // Upload image to Firebase Storage
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("product_images/\(imageName).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Firebase Storage Upload Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }

    // Save product data to Firestore (with image upload)
    func saveProduct(
            userID: String,
            name: String,
            price: Double,
            description: String,
            categoryID: String,
            gender: String,
            condition: String,
            image: UIImage?,
            completion: @escaping (Bool) -> Void
        ) {
            isSubmitting = true
            errorMessage = nil

            if let image = image {
                uploadImage(image) { imageURL in
                    if let imageURL = imageURL {
                        self.saveToFirestore(
                            userID: userID,
                            name: name,
                            price: price,
                            description: description,
                            categoryID: categoryID,
                            gender: gender,
                            condition: condition,
                            imageURL: imageURL,
                            completion: completion
                        )
                    } else {
                        DispatchQueue.main.async {
                            self.isSubmitting = false
                            self.errorMessage = "Image upload failed."
                            completion(false)
                        }
                    }
                }
            } else {
                self.saveToFirestore(
                    userID: userID,
                    name: name,
                    price: price,
                    description: description,
                    categoryID: categoryID,
                    gender: gender,
                    condition: condition,
                    imageURL: nil,
                    completion: completion
                )
            }
        }

        // Helper function to store product in Firestore
        private func saveToFirestore(
            userID: String,
            name: String,
            price: Double,
            description: String,
            categoryID: String,
            gender: String,
            condition: String,
            imageURL: String?,
            completion: @escaping (Bool) -> Void
        ) {
            let newProduct = Product(
                name: name,
                price: price,
                description: description,
                imageURL: imageURL,
                sellerID: userID,
                categoryID: categoryID,
                gender: gender,
                condition: condition
            )

            let db = Firestore.firestore()
            do {
                try db.collection("products").addDocument(from: newProduct) { error in
                    DispatchQueue.main.async {
                        self.isSubmitting = false
                        if let error = error {
                            self.errorMessage = "Failed to add product: \(error.localizedDescription)"
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSubmitting = false
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }

    // Toggle like/unlike a product
    func toggleLike(product: Product) {
        guard let userID = userID, let productID = product.id else { return }
        let userLikesRef = db.collection("users").document(userID).collection("likes").document(productID)

        if likedProducts.contains(where: { $0.id == productID }) {
            // Unlike the product
            userLikesRef.delete { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.likedProducts.removeAll { $0.id == productID }
                    }
                }
            }
        } else {
            // Like the product
            do {
                try userLikesRef.setData(from: product) { error in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.likedProducts.append(product)
                        }
                    }
                }
            } catch {
                print("Error liking product: \(error.localizedDescription)")
            }
        }
    }

    // Sort products by creation date
    var sortedProducts: [Product] {
        products.sorted { $0.createdAt > $1.createdAt } // Newest first
    }
}
