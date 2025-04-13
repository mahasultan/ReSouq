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
                    self.markProductsAsSold(cart.products)
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
    
    func markProductsAsSold(_ products: [CartItem]) {
        for cartItem in products {
            guard let productID = cartItem.product.productID else {
                print("Product ID is nil for: \(cartItem.product.name)")
                continue
            }

            let productRef = db.collection("products").document(productID)
            print("Attempting to mark as sold: \(cartItem.product.name), ID: \(cartItem.product.productID ?? "nil")")
            productRef.updateData(["isSold": true]) { error in
                if let error = error {
                    print("Error updating product \(productID): \(error.localizedDescription)")
                } else {
                    print("Product marked as sold: \(productID)")
                }
            }
        }
    }

    func fetchRatedProductIDs(for orderID: String, completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        db.collection("sellerRatings")
            .whereField("orderID", isEqualTo: orderID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch ratings: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let ratedIDs = snapshot?.documents.compactMap { $0["productID"] as? String } ?? []
                print("Rated productIDs: \(ratedIDs)")
                completion(ratedIDs)
            }
    }
    
    func confirmOrder(
        userID: String,
        cart: Cart,
        shippingAddress: String,
        authViewModel: AuthViewModel,
        cartViewModel: CartViewModel,
        productViewModel: ProductViewModel,
        onSuccess: @escaping (Order) -> Void,
        onFailure: @escaping () -> Void
    ) {
        let finalAddress = shippingAddress.trimmingCharacters(in: .whitespaces)
        guard !finalAddress.isEmpty else {
            print("ERROR: Shipping address is empty.")
            onFailure()
            return
        }

        self.placeOrder(userID: userID, cart: cart, shippingAddress: finalAddress) { savedOrder in
            DispatchQueue.main.async {
                if let savedOrder = savedOrder {
                    authViewModel.saveShippingAddress(finalAddress)
                    self.markProductsAsSold(cart.products)
                    productViewModel.fetchProducts()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        cartViewModel.clearCart()
                    }

                    onSuccess(savedOrder)
                } else {
                    print("Order failed to save.")
                    onFailure()
                }
            }
        }
    }


}
