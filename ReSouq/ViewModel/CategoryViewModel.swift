//
//  CategoryViewModel.swift
//  ReSouq
//
//

import FirebaseFirestore
import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var displayedCategories: [Category] = []

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
                self.categories = documents.compactMap { doc in
                    let data = doc.data()
                    return Category(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        parentCategoryID: data["parentCategoryID"] as? String
                    )
                }
                print("Categories Loaded: \(self.categories.count)")
            }
        }
    }

    func fetchDisplayedCategories() {
        fetchCategories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.categories.isEmpty {
                print("No categories loaded!")
            } else {
                self.displayedCategories = self.categories.prefix(3).map { $0 }
                print("Displayed Categories: \(self.displayedCategories.count)")
            }
        }
    }
}


