//
//  HomeView.swift
//  ReSouq
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var productVM = ProductViewModel()
    @StateObject var categoryVM = CategoryViewModel()
    @StateObject var cartVM = CartViewModel()

    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 5) {
                        HStack(spacing: 10) {
                            Image("Logo-2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)
                                .padding(.leading, 10)

                            SearchBarView(searchText: $searchText, isSearching: $isSearching)
                                .frame(width: 180, height: 30)
                                .padding(.leading, 20)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Shop by Category")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                if categoryVM.displayedCategories.isEmpty {
                                    Text("No categories found.")
                                        .foregroundColor(.red)
                                        .padding()
                                } else {
                                    ForEach(categoryVM.displayedCategories.prefix(4)) { category in
                                        NavigationLink(destination: CategoryProductsView(categoryID: category.id, categoryName: category.name)) {
                                            CategoryBox(category: category)
                                        }
                                    }
                                }

                                // "See All" Button
                                NavigationLink(destination: CategoriesView()) {
                                    CategoryBox(isSeeAll: true)
                                }
                            }
                            .padding(.horizontal)

                            Text("New Listings")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    if productVM.sortedProducts.isEmpty {
                                        Text("No products found.")
                                            .foregroundColor(.red)
                                            .padding()
                                    } else {
                                        ForEach(productVM.sortedProducts) { product in
                                            ProductItem(product: product)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }

                    VStack {
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .onAppear {
                productVM.fetchProducts()
                categoryVM.fetchDisplayedCategories()
            }
            .navigationDestination(isPresented: $isSearching) {
                SearchResultsView(searchQuery: searchText)
            }
        }
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(CategoryViewModel())
            .environmentObject(ProductViewModel())
            .environmentObject(CartViewModel())
    }
}
