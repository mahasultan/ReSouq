//
//  LikesView.swift
//  ReSouq
//

import SwiftUI
import SDWebImageSwiftUI

struct LikesView: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var recentlyViewedProducts: [Product] = []

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TopBarView(showLogoutButton: false, showAddButton: false)

                    if !recentlyViewedProducts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recently Viewed")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(recentlyViewedProducts) { product in
                                        NavigationLink(destination: ProductDetailView(product: product)) {
                                            WebImage(url: URL(string: product.imageUrls.first ?? ""))
                                                .resizable()
                                                .indicator(.activity)
                                                .scaledToFill()
                                                .frame(width: 65, height: 65)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }

                    Text("Wishlist")
                        .font(.custom("ReemKufi-Bold", size: 28))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    if productViewModel.likedProducts.isEmpty {
                        Text("No liked products yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(productViewModel.likedProducts, id: \.productID) { product in
                                    VStack {
                                        HStack {
                                            if let imageURL = product.imageUrls.first, let url = URL(string: imageURL) {
                                                WebImage(url: url)
                                                    .resizable()
                                                    .indicator(.activity)
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .clipped()
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .foregroundColor(.gray)
                                            }

                                            NavigationLink(destination: ProductDetailView(product: product)) {
                                                VStack(alignment: .leading) {
                                                    Text(product.name)
                                                        .font(.system(size: 18, weight: .bold))
                                                        .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))

                                                    Text("QR \(String(format: "%.2f", product.price))")
                                                        .foregroundColor(.black)
                                                        .font(.system(size: 16))
                                                }
                                            }

                                            Spacer()

                                            VStack {
                                                Button(action: {
                                                    productViewModel.toggleLike(product: product)
                                                }) {
                                                    Image(systemName: "heart.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                                }

                                                if product.isSold ?? false {
                                                    Text("Sold Out")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.gray)
                                                        .padding(.top, 2)
                                                }
                                            }

                                            if product.isSold == false {
                                                Button(action: {
                                                    cartViewModel.addProduct(product)
                                                }) {
                                                    Image(systemName: "cart.badge.plus")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                                }
                                            }
                                        }
                                        .padding(.horizontal)

                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
            .onAppear {
                productViewModel.fetchLikedProducts()
                loadRecentlyViewed()
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    func loadRecentlyViewed() {
        let recentlyViewedIDs = UserDefaults.standard.array(forKey: "recentlyViewed") as? [String] ?? []
        
        recentlyViewedProducts = productViewModel.products.filter { product in
            if let productID = product.id {
                return recentlyViewedIDs.contains(productID)
            }
            return false
        }
        .sorted { (product1, product2) -> Bool in
            guard let index1 = recentlyViewedIDs.firstIndex(of: product1.id ?? ""),
                  let index2 = recentlyViewedIDs.firstIndex(of: product2.id ?? "") else {
                return false
            }
            return index1 > index2  
        }
    }
}
