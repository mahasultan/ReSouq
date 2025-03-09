//
//  ProductDetailView.swift
//  ReSouq
//
//

import SwiftUI

struct ProductDetailView: View {
    var product: Product

    var body: some View {
        VStack {
            if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .scaledToFit()
                .frame(height: 300)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
            }

            Text(product.name)
                .font(.title)
                .bold()

            Text("QR \(product.price, specifier: "%.2f")")
                .foregroundColor(.red)
                .font(.title2)

            Text(product.description)
                .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Item Details")
    }
}

