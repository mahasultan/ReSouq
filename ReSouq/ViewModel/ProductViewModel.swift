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

    // Get products with optional category and search filters
    func getProducts(categoryID: String? = nil, searchQuery: String? = nil, categories: [Category]) -> [Product] {
        var filteredProducts = products

        if let categoryID = categoryID {
            let subcategoryIDs = categories
                .filter { $0.parentCategoryID == categoryID }
                .map { $0.id }

            filteredProducts = filteredProducts.filter { product in
                product.categoryID == categoryID || subcategoryIDs.contains(product.categoryID)
            }
        }

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

    func updateProduct(productID: String, updatedProduct: Product, newImage: UIImage?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()

        if let newImage = newImage {
            // If a new image is uploaded, update it in Firebase Storage first
            uploadImage(newImage) { imageURL in
                if let imageURL = imageURL {
                    var productWithNewImage = updatedProduct
                    productWithNewImage.imageURL = imageURL // Update the product with new image URL
                    self.saveProductUpdate(productID: productID, updatedProduct: productWithNewImage, completion: completion)
                } else {
                    self.saveProductUpdate(productID: productID, updatedProduct: updatedProduct, completion: completion)
                }
            }
        } else {
            // No new image was selected, just update other fields
            self.saveProductUpdate(productID: productID, updatedProduct: updatedProduct, completion: completion)
        }
    }

    private func saveProductUpdate(productID: String, updatedProduct: Product, completion: @escaping () -> Void) {
        let db = Firestore.firestore()

        let productData: [String: Any] = [
            "name": updatedProduct.name,
            "price": updatedProduct.price,
            "description": updatedProduct.description,
            "categoryID": updatedProduct.categoryID,
            "gender": updatedProduct.gender,
            "condition": updatedProduct.condition,
            "sellerID": updatedProduct.sellerID,
            "imageURL": updatedProduct.imageURL ?? "",
            "createdAt": updatedProduct.createdAt
        ]

        db.collection("products").document(productID).setData(productData, merge: true) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.fetchProducts() // Refresh product list
                    completion()
                }
            }
        }
    }

    // Save product to Firestore
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

    // Sort products by creation date and limit to 10 newest products
    var sortedProducts: [Product] {
        products.sorted { $0.createdAt > $1.createdAt } // Newest first
            .prefix(10) // Take only the first 10
            .map { $0 } // Convert back to an array
    }
}
