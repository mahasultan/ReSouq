import FirebaseFirestore

import SwiftUI

struct Bid: Identifiable {
    var id: String
    var amount: Double
}


class BidViewModel: ObservableObject {
    
    @Published var bids: [Bid] = []
    @Published var pastBids: [Bid] = []

    func fetchBids(for productID: String) {
        let db = Firestore.firestore()
        let bidsRef = db.collection("products").document(productID).collection("bids")

        bidsRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            var active: [Bid] = []
            var past: [Bid] = []

            for doc in docs {
                let data = doc.data()
                let bid = Bid(
                    id: data["bidderID"] as? String ?? "",
                    amount: data["amount"] as? Double ?? 0
                )

                if (data["status"] as? String) == "accepted" {
                    past.append(bid)
                } else {
                    active.append(bid)
                }
            }

            self.bids = active
            self.pastBids = past
        }
    }

    
    func acceptBid(for product: Product, bidderID: String, bidAmount: Double, completion: @escaping (Bool) -> Void) {
        guard let productID = product.id else {
            print("❌ Invalid product ID")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let productRef = db.collection("products").document(productID)
        let bidRef = db.collection("products").document(productID).collection("bids").document(bidderID)

        // 1. Update product data first
        productRef.updateData([
            "price": bidAmount,
            "buyerID": bidderID,
            "currentBid": bidAmount
        ]) { error in
            if let error = error {
                print("❌ Failed to update product: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Product updated with accepted offer.")

                // 2. Mark bid as accepted
                bidRef.updateData(["status": "accepted"]) { error in
                    if let error = error {
                        print("❌ Failed to update bid status: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("✅ Bid marked as accepted.")

                        // 3. Add to buyer's cart
                        self.addToBuyerCart(product: product, bidderID: bidderID, updatedPrice: bidAmount, completion: completion)
                    }
                }
            }
        }
    }

    
    func submitBid(for product: Product, amount: String, bidderID: String, completion: @escaping (Bool) -> Void) {
        guard let productID = product.productID,
              let bidAmount = Double(amount),
              bidAmount > 0 else {
            print("⚠️ Invalid bid input")
            completion(false)
            return
        }

        let bidData: [String: Any] = [
            "bidderID": bidderID,
            "amount": bidAmount,
            "timestamp": Timestamp(date: Date())
        ]

        let db = Firestore.firestore()
        db.collection("products")
            .document(productID)
            .collection("bids")
            .document(bidderID) // Each user can only place 1 bid; overwrite if needed
            .setData(bidData) { error in
                if let error = error {
                    print("❌ Failed to submit bid: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Bid submitted successfully!")
                    completion(true)
                }
            }
    }
    

    private func addToBuyerCart(product: Product, bidderID: String, updatedPrice: Double, completion: @escaping (Bool) -> Void) {
        guard let productID = product.id else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let cartRef = db.collection("users").document(bidderID).collection("cart")

        let productData: [String: Any] = [
            "id": productID,
            "product": [
                "id": product.id ?? "",
                "productID": product.productID ?? "",
                "name": product.name,
                "price": updatedPrice,
                "description": product.description,
                "imageUrls": product.imageUrls,
                "sellerID": product.sellerID,
                "categoryID": product.categoryID,
                "gender": product.gender,
                "condition": product.condition,
                "size": product.size ?? "",
                "isSold": true,
                "currentBid": updatedPrice
            ]
        ]

        cartRef.document(productID).setData(productData) { error in
            if let error = error {
                print("❌ Failed to add to cart: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Product added to buyer's cart.")
                completion(true)
            }
        }
    }
}
