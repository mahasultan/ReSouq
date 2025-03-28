//
//  AllProductsView.swift
//  ReSouq
//
//
import SwiftUI

struct AllProductsView: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    let columns = [
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40)
    ]

    var body: some View {
        VStack {
            Text("All Products")
                .font(.custom("ReemKufi-Bold", size: 24))
                .padding(.top, 10)

            if productViewModel.products.isEmpty {
                Text("No products found.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(productViewModel.products.sortedByAvailabilityThenDate()) { product in
                            ProductItem(product: product)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            productViewModel.fetchProducts()
        }
    }
}

