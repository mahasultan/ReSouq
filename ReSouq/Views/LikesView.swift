//
//  LikesView.swift
//  ReSouq
//
//

import SwiftUI
import SDWebImageSwiftUI

struct LikesView: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TopBarView(showLogoutButton: false, showAddButton: false)

                    Text("Wishlist")
                        .font(.custom("ReemKufi-Bold", size: 28))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    if productViewModel.likedProducts.isEmpty {
                        Text("No liked products yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(productViewModel.likedProducts, id: \.id) { product in
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

                                            Button(action: {
                                                productViewModel.toggleLike(product: product)
                                            }) {
                                                Image(systemName: "heart.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                            }

                                            Button(action: {
                                                cartViewModel.addProduct(product)
                                            }) {
                                                Image(systemName: "cart.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .padding(.horizontal)

                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }

                VStack {

                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .onAppear {
                productViewModel.fetchLikedProducts()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
