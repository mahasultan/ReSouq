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

    let columns = [
            GridItem(.flexible(), spacing: 50),
            GridItem(.flexible(), spacing: 50)
        ]

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
                    LazyVGrid(columns: columns, spacing: 20) {
                                          ForEach(filteredProducts) { product in
                                              ProductItem(product: product)
                                                  .frame(maxWidth: .infinity)
                                          }
                                      }
                                      .padding(.horizontal, 25)
                                      .padding(.bottom, 25)  
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

