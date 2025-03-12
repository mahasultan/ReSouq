//
//  SearchResultsView.swift
//  ReSouq
//

import SwiftUI

struct SearchResultsView: View {
    var searchQuery: String
    @StateObject var productVM = ProductViewModel()
    @StateObject var categoryVM = CategoryViewModel()

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
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(filteredProducts) { product in
                            ProductItem(product: product)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            productVM.fetchProducts()
            categoryVM.fetchCategories()
        }
    }
}
