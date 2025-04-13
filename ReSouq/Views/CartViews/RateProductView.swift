import SwiftUI
import FirebaseFirestore

struct RateProductView: View {
    var product: Product
    var orderID: String
    var sellerID: String
    var buyerID: String

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = RatingViewModel()
    @State private var rating: Int = 0
    @State private var reviewText: String = ""

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Rate This Product")
                    .font(.custom("ReemKufi-Bold", size: 26))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(buttonColor)

                if let imageUrl = product.imageUrls.first, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(height: 160)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 200, maxHeight: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.bottom, 8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Text(product.name)
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

                TextEditor(text: $reviewText)
                    .padding()
                    .frame(height: 100)
                    .background(backgroundColor)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                Button(action: {
                    viewModel.submitRating(
                        for: product,
                        orderID: orderID,
                        sellerID: sellerID,
                        buyerID: buyerID,
                        rating: rating,
                        reviewText: reviewText
                    ) { success in
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    Text("Submit Rating")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isSubmitting)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(buttonColor)
                }
            }
        }
    }
}
