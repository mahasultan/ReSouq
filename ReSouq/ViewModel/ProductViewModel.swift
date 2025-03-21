import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import FirebaseAuth

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var likedProducts: [Product] = []


    private let db = Firestore.firestore()

    // Upload multiple images
    func uploadImages(_ images: [UIImage], completion: @escaping ([String]?) -> Void) {
        var imageUrls: [String] = []
        let dispatchGroup = DispatchGroup()

        for image in images {
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                dispatchGroup.leave()
                continue
            }

            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("product_images/\(imageName).jpg")

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Firebase Storage Upload Error: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                storageRef.downloadURL { url, error in
                    if let url = url {
                        imageUrls.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(imageUrls.isEmpty ? nil : imageUrls)
        }
    }

    // Save product with multiple images
    func saveProduct(
        userID: String,
        name: String,
        price: Double,
        description: String,
        categoryID: String,
        gender: String,
        condition: String,
        images: [UIImage],
        completion: @escaping (Bool) -> Void
    ) {
        isSubmitting = true

        uploadImages(images) { imageUrls in
            guard let imageUrls = imageUrls else {
                self.isSubmitting = false
                self.errorMessage = "Image upload failed."
                completion(false)
                return
            }

            let newDocRef = self.db.collection("products").document() // Create a Firestore reference
            let newProduct = Product(
                id: newDocRef.documentID,  // Assign Firestore ID
                productID: newDocRef.documentID,  // Ensure Firestore ID is saved
                name: name,
                price: price,
                description: description,
                imageUrls: imageUrls,
                sellerID: userID,
                categoryID: categoryID,
                gender: gender,
                condition: condition,
                isSold: false
            )

            print("Saving product to Firestore with ID: \(newDocRef.documentID)")

            do {
                try newDocRef.setData(from: newProduct) { error in
                    DispatchQueue.main.async {
                        self.isSubmitting = false
                        if let error = error {
                            self.errorMessage = "Failed to save product: \(error.localizedDescription)"
                            completion(false)
                        } else {
                            print("Product saved with ID: \(newDocRef.documentID)")
                            completion(true)
                        }
                    }
                }
            } catch {
                self.isSubmitting = false
                self.errorMessage = "Encoding error: \(error.localizedDescription)"
                completion(false)
            }
        }
    }


    func updateProduct(
        productID: String,
        name: String,
        price: Double,
        description: String,
        categoryID: String,
        gender: String,
        condition: String,
        images: [UIImage],
        existingImageUrls: [String],
        completion: @escaping (Bool) -> Void
    ) {
        isSubmitting = true

        // Upload new images if selected, otherwise keep existing ones
        if images.isEmpty {
            saveUpdatedProduct(productID: productID, name: name, price: price, description: description, categoryID: categoryID, gender: gender, condition: condition, imageUrls: existingImageUrls, completion: completion)
        } else {
            uploadImages(images) { uploadedUrls in
                guard let uploadedUrls = uploadedUrls else {
                    self.isSubmitting = false
                    self.errorMessage = "Failed to upload images."
                    completion(false)
                    return
                }

                let finalImageUrls = existingImageUrls + uploadedUrls
                self.saveUpdatedProduct(productID: productID, name: name, price: price, description: description, categoryID: categoryID, gender: gender, condition: condition, imageUrls: finalImageUrls, completion: completion)
            }
        }
    }

    private func saveUpdatedProduct(
        productID: String,
        name: String,
        price: Double,
        description: String,
        categoryID: String,
        gender: String,
        condition: String,
        imageUrls: [String],
        completion: @escaping (Bool) -> Void
    ) {
        let productData: [String: Any] = [
            "name": name,
            "price": price,
            "description": description,
            "categoryID": categoryID,
            "gender": gender,
            "condition": condition,
            "imageUrls": imageUrls
        ]

        db.collection("products").document(productID).updateData(productData) { error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if let error = error {
                    self.errorMessage = "Failed to update product: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    func fetchLikedProducts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("likedProducts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching liked products: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.likedProducts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Product.self)
                } ?? []
            }
        }
    }
    func toggleLike(product: Product) {
        guard let userID = Auth.auth().currentUser?.uid, let productID = product.productID else { return }

        let userRef = db.collection("users").document(userID).collection("likedProducts")

        if likedProducts.contains(where: { $0.id == productID }) {
            userRef.document(productID).delete { error in
                if let error = error {
                    print("Error removing product from likes: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.likedProducts.removeAll { $0.id == productID }
                    }
                }
            }
        } else {
            do {
                try userRef.document(productID).setData(from: product)
                DispatchQueue.main.async {
                    self.likedProducts.append(product)
                }
            } catch {
                print("Error adding product to likes: \(error.localizedDescription)")
            }
        }
    }
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.products = snapshot?.documents.compactMap { document in
                    var product = try? document.data(as: Product.self)
                    product?.productID = document.documentID // Ensure Firestore ID is set
                    return product
                } ?? []

                print("Products fetched successfully. Total: \(self.products.count)")
                for product in self.products {
                    print("Product: \(product.name), ID: \(product.productID ?? "MISSING")")
                }
            }
        }
    }

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

        return filteredProducts
    }

    var sortedProducts: [Product] {
        products.sorted { $0.createdAt > $1.createdAt } // Newest first
            .prefix(10) // Take only the first 10
            .map { $0 } // Convert back to an array
    }



}
