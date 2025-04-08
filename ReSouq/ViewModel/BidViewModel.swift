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
            print("invalid product ID")
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
                print(" Failed to update product: \(error.localizedDescription)")
                completion(false)
            } else {
                print(" Product updated with accepted offer.")

                // 2. Mark bid as accepted
                bidRef.updateData(["status": "accepted"]) { error in
                    if let error = error {
                        print("Failed to update bid status: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Bid marked as accepted.")

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
            print("Invalid bid input")
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
                    print("Failed to submit bid: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print(" Bid submitted successfully!")
                    completion(true)
                }
            }
    }
    
    func allowedBidOptions(for product: Product) -> [Double] {
        let basePrice = product.price
        let reductions: [Double]

        switch product.condition {
        case "New":
            reductions = [0.95, 0.94, 0.93] // 5%, 6%, 7%
        case "Used - Like New":
            reductions = [0.92, 0.91, 0.90] // 8%, 9%, 10%
        case "Used - Good":
            reductions = [0.89, 0.88, 0.87] // 11%, 12%, 13%
        case "Used - Acceptable":
            reductions = [0.86, 0.85, 0.84] // 14%, 15%, 16%
        default:
            reductions = [0.95, 0.94, 0.93] // fallback to New
        }

        return reductions.map { Double(round(basePrice * $0)) }
    }

    private func addToBuyerCart(product: Product, bidderID: String, updatedPrice: Double, completion: @escaping (Bool) -> Void) {
        guard let productID = product.productID, !productID.isEmpty else {
            print("Missing productID")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let cartRef = db.collection("carts").document(bidderID)

        cartRef.getDocument { snapshot, error in
            var updatedProducts: [[String: Any]] = []

            if let data = snapshot?.data(), let existingProducts = data["products"] as? [[String: Any]] {
                updatedProducts = existingProducts
            }

            // Check if product already exists
            let alreadyExists = updatedProducts.contains {
                guard let productDict = $0["product"] as? [String: Any] else { return false }
                return productDict["productID"] as? String == productID
            }

            if alreadyExists {
                print("Product already in cart")
                completion(true)
                return
            }

            let newItem: [String: Any] = [
                "id": UUID().uuidString,
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

            updatedProducts.append(newItem)

            let cartData: [String: Any] = [
                "userID": bidderID,
                "products": updatedProducts
            ]

            cartRef.setData(cartData, merge: true) { error in
                if let error = error {
                    print("Failed to update buyer's cart: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Product successfully added to buyer's cart (/carts/\(bidderID))")
                    completion(true)
                }
            }
        }
    }

}
