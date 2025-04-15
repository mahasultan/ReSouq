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

    
    func acceptBid(for product: Product, bidderID: String, bidAmount: Double, expiryHours: Double, completion: @escaping (Bool) -> Void){
        guard let productID = product.id else {
            print("Invalid product ID")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let productRef = db.collection("products").document(productID)
        let bidRef = db.collection("products").document(productID).collection("bids").document(bidderID)

        let acceptedAt = Date()
        let minutes = Int(expiryHours * 60)
        let expiresAt = Calendar.current.date(byAdding: .minute, value: minutes, to: acceptedAt) ?? acceptedAt


        // 1. Update product data
        productRef.updateData([
            "price": bidAmount,
            "buyerID": bidderID,
            "currentBid": bidAmount,
            "offerAcceptedAt": Timestamp(date: acceptedAt),
            "offerExpiresAt": Timestamp(date: expiresAt),
            "originalPrice": product.price // store original in case it's not stored
        ]) { error in
            if let error = error {
                print("Failed to update product: \(error.localizedDescription)")
                completion(false)
            } else {
                // 2. Mark bid as accepted and save time
                bidRef.updateData([
                    "status": "accepted",
                    "acceptedAt": Timestamp(date: acceptedAt),
                    "expiryDurationHours": expiryHours,
                    "expiresAt": Timestamp(date: expiresAt)
                ]) { error in
                    if let error = error {
                        print("Failed to update bid status: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Bid marked as accepted for \(expiryHours) hours.")
                        completion(true)
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
        let now = Date()
        let calendar = Calendar.current

        // Calculate weeks since creation
        let weeksSinceCreated = calendar.dateComponents([.weekOfYear], from: product.createdAt, to: now).weekOfYear ?? 0

        //  Start with 2% base discount and grow by 3% per week
        let baseDiscount = 2 + (weeksSinceCreated * 3)

        // Create 3 discount steps (e.g., 5%, 6%, 7%), capped at 50%
        let discounts = (0..<3).map { step in
            min(baseDiscount + step, 50)
        }

        // Calculate bid suggestions without rounding duplicates
        var uniquePrices = Set<Double>()
        var finalSuggestions: [Double] = []

        for discount in discounts {
            let multiplier = 1.0 - (Double(discount) / 100.0)
            let suggestedPrice = round(basePrice * multiplier)

            if !uniquePrices.contains(suggestedPrice) {
                uniquePrices.insert(suggestedPrice)
                finalSuggestions.append(suggestedPrice)
            }
        }

        //  If suggestions aren't unique enough, try next discount steps
        var nextStep = 3
        while finalSuggestions.count < 3 && baseDiscount + nextStep <= 50 {
            let discount = baseDiscount + nextStep
            let multiplier = 1.0 - (Double(discount) / 100.0)
            let suggestedPrice = round(basePrice * multiplier)

            if !uniquePrices.contains(suggestedPrice) {
                uniquePrices.insert(suggestedPrice)
                finalSuggestions.append(suggestedPrice)
            }

            nextStep += 1
        }

        return finalSuggestions
    }


}
