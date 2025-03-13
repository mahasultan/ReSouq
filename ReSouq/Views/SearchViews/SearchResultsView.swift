//
//  SearchResultsView.swift
//  ReSouq
//

import SwiftUI

struct SearchResultsView: View {
    var searchQuery: String
    @StateObject var productVM = ProductViewModel()
    @StateObject var categoryVM = CategoryViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40)       ]

    var body: some View {
        VStack {
            Text("Search Results for '\(searchQuery)'")
                .font(.custom("ReemKufi-Bold", size: 22))
                .padding(.top, 10)

            let filteredProducts = productVM.getProducts(searchQuery: searchQuery, categories: categoryVM.categories)

            if filteredProducts.isEmpty {
                Text("No results found.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredProducts) { product in
                            ProductItem(product: product)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            productVM.fetchProducts()
            categoryVM.fetchCategories()
        }
    }
}
