//
//  CategoryProductsView.swift
//  ReSouq
//
//


import SwiftUI

struct CategoryProductsView: View {
    var categoryID: String
    var categoryName: String
    @StateObject var productVM = ProductViewModel()

    var body: some View {
        VStack {
            Text(categoryName)
                .font(.title)
                .bold()
                .padding(.top)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    ForEach(productVM.products.filter { $0.categoryID == categoryID }) { product in
                        ProductItem(product: product)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            productVM.fetchProducts()
        }
    }
}
