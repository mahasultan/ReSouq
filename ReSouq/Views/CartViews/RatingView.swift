//
//  RatingView.swift
//  ReSouq
//

import SwiftUI
import FirebaseFirestore

struct RatingView: View {
    @Binding var order: Order
    @Environment(\.dismiss) var dismiss
    @State private var rating: Int = 0 // No pre-filled stars
    @State private var reviewText: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Rate Seller")
                    .font(.custom("ReemKufi-Bold", size: 28))
                    .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 12) {
                    Text("How was your experience?")
                        .font(.headline)

                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Leave a comment (optional)")
                        .font(.headline)

                    TextEditor(text: $reviewText)
                        .padding(10)
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: submitRating) {
                    Text("Submit Rating")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) // Maroon color
                    }
                }
            }
        }
    }

    func submitRating() {
        guard let orderID = order.id,
              let sellerID = order.products.first?.product.sellerID else {
            print("Missing order ID or seller ID")
            return
        }

        let db = Firestore.firestore()
        let userID = order.userID

        db.collection("sellerRatings")
            .whereField("orderID", isEqualTo: orderID)
            .whereField("buyerID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents, !docs.isEmpty {
                    print("Rating already exists.")
                    dismiss()
                    return
                }

                let newRating = SellerRating(
                    orderID: orderID,
                    sellerID: sellerID,
                    buyerID: userID,
                    rating: rating,
                    reviewText: reviewText
                )

                do {
                    _ = try db.collection("sellerRatings").addDocument(from: newRating)

                    // Update Firestore
                    db.collection("orders").document(orderID).updateData(["isRated": true])

                    // Update local copy
                    order.isRated = true

                    print("Rating saved and order marked as rated.")
                    dismiss()
                } catch {
                    print("Error saving rating: \(error.localizedDescription)")
                }
            }
    }
}
