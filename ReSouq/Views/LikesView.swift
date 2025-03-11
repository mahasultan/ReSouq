//
//  LikesView.swift
//  ReSouq
//
//

import SwiftUI
import SDWebImageSwiftUI

struct LikesView: View {
    @EnvironmentObject var productViewModel: ProductViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if productViewModel.likedProducts.isEmpty {
                    Text("No liked products yet.")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(productViewModel.likedProducts, id: \.id) { product in
                            HStack {
                                if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .indicator(.activity)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .clipped()
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(product.name)
                                        .font(.headline)
                                    Text("QR \(String(format: "%.2f", product.price))")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }

                                Spacer()

                                // ✅ Unlike Button (Removes Product from Likes)
                                Button(action: {
                                    productViewModel.toggleLike(product: product)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let product = productViewModel.likedProducts[index]
                                productViewModel.toggleLike(product: product)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Liked Products")
            .onAppear {
                productViewModel.fetchLikedProducts()
            }
        }
    }
}

