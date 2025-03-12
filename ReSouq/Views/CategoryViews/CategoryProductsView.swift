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
    @StateObject var categoryVM = CategoryViewModel()

    var body: some View {
        VStack {
            Text("\(categoryName) Products")
                .font(.custom("ReemKufi-Bold", size: 22))
                .padding(.top, 10)

            let filteredProducts = productVM.getProducts(categoryID: categoryID, categories: categoryVM.categories)

            if filteredProducts.isEmpty {
                Text("No products found.")
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
        .navigationTitle(categoryName)
        .onAppear {
            productVM.fetchProducts()
            categoryVM.fetchCategories()
        }
    }
}

