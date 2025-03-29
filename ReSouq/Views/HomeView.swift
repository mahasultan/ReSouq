//
//  HomeView.swift
//  ReSouq
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @StateObject var categoryViewModel = CategoryViewModel()
    @StateObject var cartVM = CartViewModel()

    @State private var searchText = ""
    @State private var destinationQuery: SearchQuery? = nil
    @State private var selectedFilters = FilterOptions()
    @State private var showFilterSheet = false
    @State private var didApplyFilters = false

    private let maroon = Color(red: 120/255, green: 0, blue: 0)

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

                            SearchBarView(searchText: $searchText) {
                                destinationQuery = SearchQuery(
                                    query: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                                    filters: selectedFilters
                                )
                            }
                            .frame(width: 180, height: 30)
                            .padding(.leading, 10)

                            Button(action: {
                                showFilterSheet = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(maroon)
                                    .padding(.trailing, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .background(Color(red: 232/255, green: 225/255, blue: 210/255))
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Shop by Category")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                if categoryViewModel.displayedCategories.isEmpty {
                                    Text("No categories found.")
                                        .foregroundColor(.red)
                                        .padding()
                                } else {
                                    ForEach(categoryViewModel.displayedCategories.prefix(4)) { category in
                                        NavigationLink(destination: CategoryProductsView(categoryID: category.id, categoryName: category.name)) {
                                            CategoryBox(category: category)
                                        }
                                    }
                                }

                                NavigationLink(destination: AllProductsView()) {
                                    CategoryBox(isSeeAll: true)
                                }
                            }
                            .padding(.horizontal)

                            Text("New Listings")
                                .font(.custom("ReemKufi-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    if productViewModel.sortedProducts.isEmpty {
                                        Text("No products found.")
                                            .foregroundColor(.red)
                                            .padding()
                                    } else {
                                        ForEach(productViewModel.products.sortedByAvailabilityThenDate().prefix(10)) { product in
                                            ProductItem(product: product)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .onAppear {
                productViewModel.fetchProducts()
                categoryViewModel.fetchDisplayedCategories()
            }
            .navigationDestination(item: $destinationQuery) { query in
                SearchResultsView(
                    searchQuery: query.query,
                    filters: query.filters
                )
            }
            .sheet(isPresented: $showFilterSheet, onDismiss: {
                if didApplyFilters {
                    destinationQuery = SearchQuery(
                        query: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                        filters: selectedFilters
                    )
                    didApplyFilters = false
                }
            }) {
                FilterSheetView(filters: $selectedFilters, didApplyFilters: $didApplyFilters)
                    .environmentObject(categoryViewModel)
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
