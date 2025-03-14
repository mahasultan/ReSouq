//
//  ProfileView.swift
//  ReSouq
//

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
                    // **Fixed Top Bar**
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

                    // **Scrollable Content**
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            if let user = authViewModel.user {
                                // **User Info Section inside Beige Rectangle**
                                VStack(spacing: 15) {
                                    // **Profile Icon Instead of Image**
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

                                // **My Orders Section**
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
                                            ForEach(orderViewModel.orders) { order in
                                                NavigationLink(destination: OrderDetailView(order: order)) {
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text("Order #\(order.id ?? "N/A")")
                                                            .bold()
                                                            .foregroundColor(.black)

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

                                // **My Listings Section**
                                Text("My Listings")
                                    .font(.custom("ReemKufi-Bold", size: 22))
                                    .bold()
                                    .foregroundColor(buttonColor)
                                    .padding(.leading, 20)
                                    .padding(.top, 20)

                                if productViewModel.products.isEmpty {
                                    Text("No listings found.")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 20)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(productViewModel.products.filter { $0.sellerID == authViewModel.userID }) { product in
                                                NavigationLink(destination: ProductDetailView(product: product)) {
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
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
                            } else {
                                ProgressView()
                                    .onAppear {
                                        if let userID = authViewModel.getCurrentUserID() {
                                            authViewModel.fetchUserDetails(uid: userID)
                                            orderViewModel.fetchOrders(for: userID)
                                            productViewModel.fetchProducts()
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
                        print("Fetching orders and listings for user ID: \(userID)") // Debugging
                        orderViewModel.fetchOrders(for: userID)
                        productViewModel.fetchProducts()
                    }
                }
            }
        }
    }
}

// Preview
#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(OrderViewModel())
        .environmentObject(ProductViewModel())
}
