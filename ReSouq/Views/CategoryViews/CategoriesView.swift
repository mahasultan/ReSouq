//
//  CategoriesView.swift
//  ReSouq
//
//


import SwiftUI

struct CategoriesView: View {
    @StateObject var categoryViewModel = CategoryViewModel()

    var body: some View {
        List(categoryViewModel.categories) { category in
            NavigationLink(destination: CategoryProductsView(categoryID: category.id, categoryName: category.name)) {
                Text(category.name)
            }
        }
        .onAppear {
            categoryViewModel.fetchCategories()
        }
    }
}
