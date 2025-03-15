//
//  CartViewModel.swift
//  ReSouq


import Foundation
import FirebaseFirestore
import FirebaseAuth



class CartViewModel: ObservableObject {
    @Published var cart: Cart
    
    
    @Published var soldOutProducts: Set<String> = []
    private var db = Firestore.firestore()
    
    init() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found")
            self.cart = Cart(userID: "unknown")
            return
        }
        
        self.cart = Cart(userID: userID)
        fetchCart()
    }
    
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            print("User is authenticated: \(user.uid)")
        } else {
            print("No authenticated user found")
        }
    }
    
    func fetchCart() {
        db.collection("carts").document(cart.userID).getDocument { snapshot, error in
            if let error = error {
                print("Firestore error fetching cart: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot, snapshot.exists {
                do {
                    self.cart = try snapshot.data(as: Cart.self)
                    
                    // Fetch sold-out products from Firestore
                    self.fetchSoldOutProducts()
                    
                    print("Cart loaded successfully")
                } catch {
                    print("Firestore error decoding cart: \(error.localizedDescription)")
                }
            } else {
                print("No cart found, creating a new one")
                self.createCart()
            }
        }
    }
    
    func fetchSoldOutProducts() {
        db.collection("products").whereField("isSoldOut", isEqualTo: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching sold out products: \(error.localizedDescription)")
                return
            }
            
            let soldOutIDs = snapshot?.documents.compactMap { $0.documentID } ?? []
            DispatchQueue.main.async {
                self.soldOutProducts = Set(soldOutIDs)
                print("Sold Out Products Updated: \(self.soldOutProducts)")
            }
        }
    }
    
    
    
    
    func createCart() {
        let cartRef = db.collection("carts").document(cart.userID)
        let cartData: [String: Any] = [
            "userID": cart.userID,
            "products": []
        ]
        
        cartRef.setData(cartData, merge: true) { error in
            if let error = error {
                print("Firestore error while creating cart: \(error.localizedDescription)")
            } else {
                print("New cart document created successfully")
            }
        }
    }
    
    func clearCart() {
        cart.products.removeAll()
        updateCart()
    }
    
    func addProduct(_ product: Product, quantity: Int = 1) {
        
        let userID = cart.userID
        
        let newCartItem = CartItem(product: product, quantity: quantity)
        
        if let index = cart.products.firstIndex(where: { $0.product.id == product.id }) {
            cart.products[index].quantity += quantity
        } else {
            cart.products.append(newCartItem)
        }
        
        
        let cartRef = db.collection("carts").document(userID)
        do {
            try cartRef.setData(from: cart, merge: true) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                } else {
                    print("Product added to cart and synced with Firestore")
                }
            }
        } catch {
            print("Firestore error: \(error.localizedDescription)")
        }
    }
    
    func removeProduct(_ product: Product) {
        
        if let index = cart.products.firstIndex(where: { $0.product.id == product.id }) {
            if cart.products[index].quantity > 1 {
                cart.products[index].quantity -= 1
            } else {
                cart.products.remove(at: index)
            }
            updateCart()
            
        }
    }
    
    private func updateCart() {
        let cartRef = db.collection("carts").document(cart.userID)
        do {
            try cartRef.setData(from: cart, merge: true) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                } else {
                    print("Cart updated in Firestore")
                }
            }
        } catch {
            print("Error updating cart: \(error.localizedDescription)")
        }
    }
    
    func markProductsAsSoldOut() {
        let soldOutIDs = cart.products.compactMap { $0.product.id } // Remove nil values
        
        
        print("Current Cart Products Before Marking Sold Out: \(cart.products.map { $0.product.id ?? "Unknown" })")
        print("Marking the following products as sold out: \(soldOutIDs)")
        
        DispatchQueue.main.async {
            self.soldOutProducts.formUnion(soldOutIDs)
            print("Sold Out Products Updated: \(self.soldOutProducts)")
            self.objectWillChange.send()
        }
    }
    
    
}
