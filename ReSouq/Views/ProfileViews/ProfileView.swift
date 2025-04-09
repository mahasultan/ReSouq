import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @State private var isLoggedOut = false

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textColor = Color.black
    private let secondaryTextColor = Color.gray
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 10) {
                    ZStack {
                        TopBarView(showLogoutButton: false, showAddButton: false)

                        HStack {
                            Spacer()
                            Button(action: {
                                authViewModel.logout()
                                isLoggedOut = true
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(buttonColor)
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .zIndex(1)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            if let user = authViewModel.user {
                                ZStack(alignment: .topTrailing) {
                                    VStack(spacing: 15) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)

                                        VStack(spacing: 5) {
                                            Text(user.fullName)
                                                .font(.custom("ReemKufi-Bold", size: 22))
                                                .foregroundColor(textColor)

                                            Text(user.email)
                                                .font(.custom("ReemKufi-Bold", size: 18))
                                                .foregroundColor(secondaryTextColor)

                                            Text(user.phoneNumber?.isEmpty == false ? user.phoneNumber! : "No phone number")
                                                .font(.custom("ReemKufi-Bold", size: 18))
                                                .foregroundColor(secondaryTextColor)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(backgroundColor)
                                    .cornerRadius(15)
                                    .padding(.horizontal, 20)

                                    NavigationLink(destination: EditProfileView()) {
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                            .padding(10)
                                            .background(buttonColor)
                                            .clipShape(Circle())
                                            .foregroundColor(.white)
                                            .shadow(radius: 3)
                                    }
                                    .offset(x: -40, y: 10)
                                }

                                if productViewModel.sellerRatings.filter({ $0.sellerID == user.id }).count > 0 {
                                    let reviews = productViewModel.sellerRatings.filter { $0.sellerID == user.id }
                                    let averageRating = reviews.map { Double($0.rating) }.reduce(0, +) / Double(reviews.count)

                                    VStack(spacing: 8) {
                                        Text("Average Rating: \(String(format: "%.1f", averageRating)) ⭐️")
                                            .font(.custom("ReemKufi-Bold", size: 18))
                                            .foregroundColor(buttonColor)

                                        Text("Orders Sold: \(reviews.count)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(backgroundColor)
                                    .cornerRadius(15)
                                    .padding(.horizontal, 20)
                                }

                                Text("My Orders")
                                    .font(.custom("ReemKufi-Bold", size: 22))
                                    .bold()
                                    .foregroundColor(buttonColor)
                                    .padding(.leading, 20)
                                    .padding(.top, 20)

                                if orderViewModel.orders.isEmpty {
                                    Text("No past orders found.")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 20)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(orderViewModel.orders, id: \.id) { order in
                                                NavigationLink(destination: OrderDetailView(order: order)) {
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("Order")
                                                            .font(.custom("ReemKufi-Bold", size: 18))
                                                            .foregroundColor(.black)

                                                        Text("#\(order.id ?? "N/A")")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)

                                                        Text("Date: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)

                                                        Text("Total: QR \(String(format: "%.2f", order.totalPrice))")
                                                            .font(.subheadline)
                                                            .foregroundColor(buttonColor)
                                                    }
                                                    .padding()
                                                    .frame(width: 200)
                                                    .background(backgroundColor)
                                                    .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }

                                Text("My Listings")
                                    .font(.custom("ReemKufi-Bold", size: 22))
                                    .bold()
                                    .foregroundColor(buttonColor)
                                    .padding(.leading, 20)
                                    .padding(.top, 20)

                                let userListings = productViewModel.products
                                    .filter { $0.sellerID == authViewModel.userID }
                                    .sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }

                                if userListings.isEmpty {
                                    Text("No listings found.")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 20)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(userListings, id: \.id) { product in
                                                ProductCardView(product: product)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }

                                Text("Reviews")
                                    .font(.custom("ReemKufi-Bold", size: 22))
                                    .foregroundColor(buttonColor)
                                    .padding(.leading, 20)

                                let myReviews = productViewModel.sellerRatings.filter { $0.sellerID == authViewModel.userID }

                                if myReviews.isEmpty {
                                    Text("No reviews yet.")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 20)
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(myReviews, id: \.id) { review in
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

                            } else {
                                ProgressView()
                                    .onAppear {
                                        if let userID = authViewModel.getCurrentUserID() {
                                            authViewModel.fetchUserDetails(uid: userID)
                                            orderViewModel.fetchOrders(for: userID)
                                            productViewModel.fetchProducts()
                                            productViewModel.fetchSellerRatings()
                                        }
                                    }
                            }

                            Spacer()
                        }
                    }
                }
                .background(Color.white.ignoresSafeArea())
                .onAppear {
                    if let userID = authViewModel.userID {
                        orderViewModel.fetchOrders(for: userID)
                        productViewModel.fetchProducts()
                        productViewModel.fetchSellerRatings()
                    }
                }
            }
        }
    }
}

struct ProductCardView: View {
    let product: Product
    var showOffers: Bool = true

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        VStack {
            NavigationLink(destination: ProductDetailView(product: product)) {
                VStack(alignment: .leading, spacing: 5) {
                    if let imageUrl = product.imageUrls.first, let url = URL(string: imageUrl) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    }

                    Text(product.name)
                        .bold()
                        .foregroundColor(.black)
                        .lineLimit(1)

                    Text("QR \(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .foregroundColor(buttonColor)
                }
            }

            if showOffers, let _ = product.productID {
                NavigationLink(destination: BidOffersView(product: product)) {
                    Text("Offers")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 150)
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
    }
}
