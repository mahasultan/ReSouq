//
//  CategoriesView.swift
//  ReSouq
//
//


import SwiftUI

struct CategoriesView: View {
    @StateObject var categoryVM = CategoryViewModel()

    var body: some View {
        List(categoryVM.categories) { category in
            NavigationLink(destination: CategoryProductsView(categoryID: category.id, categoryName: category.name)) {
                Text(category.name)
            }
        }
        .onAppear {
            categoryVM.fetchCategories()
        }
    }
}
