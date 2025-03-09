//
//  ProductViewModel.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 09/03/2025.
//


import FirebaseFirestore
import Foundation

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []

    private let db = Firestore.firestore()

    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }

            DispatchQueue.main.async {
                self.products = documents.compactMap { try? $0.data(as: Product.self) }
            }
        }
    }

    var sortedProducts: [Product] {
        products.sorted { $0.createdAt < $1.createdAt }
    }
}

