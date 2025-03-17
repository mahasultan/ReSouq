//
//  OrderViewModel.swift
//  ReSouq
//

import Foundation
import FirebaseFirestore

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var latestOrder: Order?

    private var db = Firestore.firestore()
    
    // Fetch orders for a specific user
    func fetchOrders(for userID: String) {
        db.collection("orders")
            .whereField("userID", isEqualTo: userID)
            .order(by: "orderDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.orders = snapshot?.documents.compactMap { doc -> Order? in
                        let order = try? doc.data(as: Order.self)
                        print("Fetched Order: \(String(describing: order))") // Debug print
                        return order
                    } ?? []
                    print("Total Orders Fetched: \(self.orders.count)")
                }
            }
    }

    // Place a new order with shipping address
    func placeOrder(userID: String, cart: Cart, shippingAddress: String, completion: @escaping (Order?) -> Void) {
        var newOrder = Order(
            userID: userID,
            products: cart.products,
            totalPrice: cart.totalPrice,
            shippingAddress: shippingAddress // Ensure shipping address is stored
        )

        let documentRef = db.collection("orders").document()
        newOrder.id = documentRef.documentID

        do {
            try documentRef.setData(from: newOrder) { error in
                if let error = error {
                    print("Firestore Error: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Order placed successfully with ID: \(newOrder.id ?? "Unknown ID") and Address: \(newOrder.shippingAddress ?? "N/A")")
                    DispatchQueue.main.async {
                        self.latestOrder = newOrder
                    }
                    completion(newOrder)
                }
            }
        } catch {
            print("Encoding Error: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
