//
//  CategoryViewModel.swift
//  ReSouq
//

import FirebaseFirestore
import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = [] // Subcategories only
    @Published var displayedCategories: [Category] = [] // Main categories only

    private let db = Firestore.firestore()

    func fetchCategories() {
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Firestore Error: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No categories found in Firestore.")
                return
            }

            DispatchQueue.main.async {
                let allCategories = documents.compactMap { doc -> Category? in
                    let data = doc.data()
                    return Category(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        parentCategoryID: data["parentCategoryID"] as? String
                    )
                }

                // Exclude main categories (those with nil parentCategoryID)
                self.categories = allCategories.filter { $0.parentCategoryID != nil }
                print("Subcategories Loaded: \(self.categories.count)")
            }
        }
    }

    func fetchDisplayedCategories() {
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Firestore Error: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No categories found in Firestore.")
                return
            }

            DispatchQueue.main.async {
                let allCategories = documents.compactMap { doc -> Category? in
                    let data = doc.data()
                    return Category(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        parentCategoryID: data["parentCategoryID"] as? String
                    )
                }

                // Only include main categories (those with nil parentCategoryID)
                self.displayedCategories = allCategories.filter { $0.parentCategoryID == nil }
                print("Main Categories Loaded: \(self.displayedCategories.count)")
            }
        }
    }
}
