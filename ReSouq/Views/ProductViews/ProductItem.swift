//
//  ProductItem.swift
//  ReSouq
//
//


import SwiftUI

struct ProductItem: View {
    var product: Product

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack {
                AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                .frame(width: 120, height: 120)
                .cornerRadius(10)

                Text(product.name)
                    .font(.system(size: 14))
                    .bold()

                Text("QR \(product.price, specifier: "%.2f")")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(width: 160)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 2)
        }
    }
}
