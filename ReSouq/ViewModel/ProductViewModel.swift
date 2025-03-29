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
        size: String?,
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
                size: size,
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
        size: String?,
        images: [UIImage],
        existingImageUrls: [String],
        completion: @escaping (Bool) -> Void
    ) {
        isSubmitting = true

        // Upload new images if selected, otherwise keep existing ones
        if images.isEmpty {
            saveUpdatedProduct(
                productID: productID,
                name: name,
                price: price,
                description: description,
                categoryID: categoryID,
                gender: gender,
                condition: condition,
                size: size,
                imageUrls: existingImageUrls,
                completion: completion
            )
        } else {
            uploadImages(images) { uploadedUrls in
                guard let uploadedUrls = uploadedUrls else {
                    self.isSubmitting = false
                    self.errorMessage = "Failed to upload images."
                    completion(false)
                    return
                }

                let finalImageUrls = existingImageUrls + uploadedUrls
                self.saveUpdatedProduct(
                    productID: productID,
                    name: name,
                    price: price,
                    description: description,
                    categoryID: categoryID,
                    gender: gender,
                    condition: condition,
                    size: size,
                    imageUrls: finalImageUrls,
                    completion: completion
                )
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
        size: String?,
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
            "imageUrls": imageUrls,
            "size": size ?? ""
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
                    var product = try? document.data(as: Product.self)

                    // Fetch the latest 'isSold' status from Firestore
                    if let productID = product?.productID {
                        self.db.collection("products").document(productID).getDocument { productSnapshot, error in
                            if let productData = productSnapshot?.data(),
                               let isSold = productData["isSold"] as? Bool {
                                DispatchQueue.main.async {
                                    if let index = self.likedProducts.firstIndex(where: { $0.productID == productID }) {
                                        self.likedProducts[index].isSold = isSold
                                        print("Updated isSold for liked product \(productID): \(isSold)")
                                    }
                                }
                            }
                        }
                    }

                    return product
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

    func getProducts(
        categoryID: String? = nil,
        searchQuery: String? = nil,
        categories: [Category],
        condition: String? = nil,
        size: String? = nil,
        gender: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sortBy: String? = nil 
    ) -> [Product] {
        var filteredProducts = products

        if let categoryID = categoryID {
            let subcategoryIDs = categories
                .filter { $0.parentCategoryID == categoryID }
                .map { $0.id }

            filteredProducts = filteredProducts.filter { product in
                product.categoryID == categoryID || subcategoryIDs.contains(product.categoryID)
            }
        }

        if let searchQuery = searchQuery?.lowercased(), !searchQuery.isEmpty {
            filteredProducts = filteredProducts.filter { product in
                let nameMatch = product.name.lowercased().contains(searchQuery)
                let genderMatch = product.gender.lowercased().contains(searchQuery) ?? false
                let conditionMatch = product.condition.lowercased().contains(searchQuery) ?? false
                let sizeMatch = product.size?.lowercased().contains(searchQuery) ?? false
                let categoryName = categories.first(where: { $0.id == product.categoryID })?.name.lowercased() ?? ""
                let categoryMatch = categoryName.contains(searchQuery)

                return nameMatch || genderMatch || conditionMatch || sizeMatch || categoryMatch
            }
        }
        
        if let sort = sortBy {
            switch sort {
            case "Price: Low → High":
                filteredProducts = filteredProducts.sorted { $0.price < $1.price }
            case "Price: High → Low":
                filteredProducts = filteredProducts.sorted { $0.price > $1.price }
            case "Newest":
                filteredProducts = filteredProducts.sorted { $0.createdAt > $1.createdAt }
            default:
                break
            }
        }


        if let condition = condition {
            filteredProducts = filteredProducts.filter { $0.condition == condition }
        }

        if let size = size {
            filteredProducts = filteredProducts.filter { $0.size == size }
        }

        if let gender = gender {
            filteredProducts = filteredProducts.filter { $0.gender == gender }
        }

        if let min = minPrice {
            filteredProducts = filteredProducts.filter { $0.price >= min }
        }

        if let max = maxPrice {
            filteredProducts = filteredProducts.filter { $0.price <= max }
        }

        return filteredProducts
    }

    var sortedProducts: [Product] {
        products
            .sorted {
                // Show unsold products first, then sort by creation date
                let isSoldA = $0.isSold ?? false
                let isSoldB = $1.isSold ?? false

                if isSoldA != isSoldB {
                    return !isSoldA && isSoldB // Unsold before sold
                } else {
                    return ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
                }
            }
            .prefix(10)
            .map { $0 }
    }




}
