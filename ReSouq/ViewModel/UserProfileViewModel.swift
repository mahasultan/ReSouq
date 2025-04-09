
import Foundation
import FirebaseFirestore

class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = true

    @Published var averageRating: Double = 0.0
    @Published var totalRatings: Int = 0
    @Published var reviews: [SellerRating] = []
    @Published var listings: [Product] = []

    private let db = Firestore.firestore()

    func loadUserProfile(userID: String) {
        fetchUserDetails(userID: userID)
        fetchSellerRatings(sellerID: userID)
        fetchSellerListings(sellerID: userID)
    }

    private func fetchUserDetails(userID: String) {
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let document = snapshot {
                self.user = try? document.data(as: User.self)
            }
            self.isLoading = false
        }
    }

    private func fetchSellerRatings(sellerID: String) {
        db.collection("sellerRatings")
            .whereField("sellerID", isEqualTo: sellerID)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    let fetchedRatings = documents.compactMap { try? $0.data(as: SellerRating.self) }
                    self.reviews = fetchedRatings
                    self.totalRatings = fetchedRatings.count
                    if self.totalRatings > 0 {
                        let totalScore = fetchedRatings.reduce(0) { $0 + $1.rating }
                        self.averageRating = Double(totalScore) / Double(self.totalRatings)
                    }
                }
            }
    }

    private func fetchSellerListings(sellerID: String) {
        db.collection("products")
            .whereField("sellerID", isEqualTo: sellerID)
            .whereField("isSold", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.listings = documents.compactMap { try? $0.data(as: Product.self) }
                }
            }
    }
}
