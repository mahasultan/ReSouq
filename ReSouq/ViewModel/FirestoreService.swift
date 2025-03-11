import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // Check if product exists in any order and mark it as sold out
    func checkAndMarkProductSold(userID: String, productID: String, completion: @escaping (Bool) -> Void) {
        db.collection("orders").whereField("userID", isEqualTo: userID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching orders: \(error)")
                completion(false)
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No orders found for user: \(userID)")
                completion(false)
                return
            }

            var productFound = false

            for document in documents {
                let orderData = document.data()
                if let products = orderData["products"] as? [[String: Any]] {
                    for product in products {
                        if let id = product["id"] as? String, id == productID {
                            productFound = true
                            break
                        }
                    }
                }
            }

            if productFound {
                self.markProductAsSold(productID: productID, completion: completion)
            } else {
                print("Product not found in any orders.")
                completion(false)
            }
        }
    }

    // Mark product as sold out
    private func markProductAsSold(productID: String, completion: @escaping (Bool) -> Void) {
        db.collection("products").document(productID).updateData([
            "availability": "sold out"
        ]) { error in
            if let error = error {
                print("Error updating product status: \(error)")
                completion(false)
            } else {
                print("Product \(productID) marked as sold out successfully.")
                completion(true)
            }
        }
    }
}
