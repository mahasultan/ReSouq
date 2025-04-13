import Foundation
import FirebaseFirestore

class RatingViewModel: ObservableObject {
    @Published var isSubmitting = false

    func submitRating(for product: Product,
                      orderID: String,
                      sellerID: String,
                      buyerID: String,
                      rating: Int,
                      reviewText: String,
                      completion: @escaping (Bool) -> Void) {
        
        guard let productFirestoreID = product.productID else {
            print("product.productID is nil — cannot update")
            completion(false)
            return
        }

        isSubmitting = true

        let db = Firestore.firestore()
        let ratingData = SellerRating(
            productID: productFirestoreID,
            orderID: orderID,
            sellerID: sellerID,
            buyerID: buyerID,
            rating: rating,
            reviewText: reviewText
        )

        do {
            _ = try db.collection("sellerRatings").addDocument(from: ratingData)

            db.collection("products").document(productFirestoreID).updateData(["isRated": true]) { error in
                if let error = error {
                    print("Error updating isRated: \(error.localizedDescription)")
                    self.isSubmitting = false
                    completion(false)
                } else {
                    print("Product marked as rated in Firestore.")
                    self.isSubmitting = false
                    completion(true)
                }
            }
        } catch {
            print("Failed to save rating: \(error.localizedDescription)")
            isSubmitting = false
            completion(false)
        }
    }
}
