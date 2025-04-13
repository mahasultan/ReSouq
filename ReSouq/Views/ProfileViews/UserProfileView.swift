import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    var userID: String
    @StateObject private var viewModel = UserProfileViewModel()

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let secondaryTextColor = Color.gray
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView(showLogoutButton: false, showAddButton: false)

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else if let user = viewModel.user {
                            VStack(spacing: 15) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)

                                Text(user.fullName)
                                    .font(.custom("ReemKufi-Bold", size: 22))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)

                            if viewModel.totalRatings > 0 {
                                VStack(spacing: 8) {
                                    Text("Average Rating: \(String(format: "%.1f", viewModel.averageRating)) ⭐️")
                                        .font(.custom("ReemKufi-Bold", size: 18))
                                        .foregroundColor(buttonColor)

                                    Text("Products Sold: \(viewModel.totalProductsSold)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(backgroundColor)
                                .cornerRadius(15)
                                .padding(.horizontal, 20)
                            } else {
                                Text("No ratings yet.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                            }

                            Text("Current Listings")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .foregroundColor(buttonColor)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.listings.isEmpty {
                                Text("No active listings.")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.listings, id: \.id) { product in
                                            ProductCardView(product: product, showOffers: false)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            Text("Reviews")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .foregroundColor(buttonColor)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.reviews.isEmpty {
                                Text("No reviews yet.")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.reviews, id: \.id) { review in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("⭐️ \(review.rating)")
                                                    .font(.headline)
                                                Spacer()
                                                Text(review.timestamp.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            if let text = review.reviewText, !text.isEmpty {
                                                Text("“\(text)”")
                                                    .italic()
                                                    .font(.body)
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            Spacer()
                        } else {
                            Text("User not found.")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top)
                }
                .background(Color.white.ignoresSafeArea())
            }
            .onAppear {
                viewModel.loadUserProfile(userID: userID)
            }
        }
    }
}
