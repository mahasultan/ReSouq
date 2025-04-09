import SwiftUI

struct FilterOptions: Hashable {
    var condition: String? = nil
    var size: String? = nil
    var gender: String? = nil
    var minPrice: Double? = nil
    var maxPrice: Double? = nil
    var categoryID: String? = nil
    var sortBy: String? = nil
}

struct SearchResultsView: View {
    var searchQuery: String
    var categoryID: String? = nil

    @State private var showFilterSheet = false
    @State private var localFilters: FilterOptions
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    private let maroon = Color(red: 120/255, green: 0, blue: 0)

    private var dynamicTitle: String {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Filtered Results" : "Search Results for '\(trimmed)'"
    }

    let columns = [
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40)
    ]

    init(searchQuery: String, categoryID: String? = nil, filters: FilterOptions) {
        self.searchQuery = searchQuery
        self.categoryID = categoryID
        self._localFilters = State(initialValue: filters)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            ZStack {
                TopBarView(showLogoutButton: false, showAddButton: false)

                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(maroon)
                    }
                    .padding(.leading)

                    Spacer()

                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(maroon)
                            .padding(.trailing)
                    }
                }
            }
            .frame(height: 50)
            .background(Color(red: 232/255, green: 225/255, blue: 210/255))
            .navigationBarBackButtonHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(dynamicTitle)
                    .font(.custom("ReemKufi-Bold", size: 22))
                    .padding(.horizontal)
                    .padding(.top, 8)

                if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Showing results based on selected filters")
                        .font(.custom("ReemKufi-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }

            VStack(spacing: 0) {
                filterChips()
                Spacer().frame(height: 12)  
            }

            let allProducts = productVM.getProducts(
                categoryID: localFilters.categoryID ?? categoryID,
                searchQuery: searchQuery,
                categories: categoryViewModel.categories,
                condition: localFilters.condition,
                size: localFilters.size,
                gender: localFilters.gender,
                minPrice: localFilters.minPrice,
                maxPrice: localFilters.maxPrice,
                sortBy: localFilters.sortBy
            )

            let topSellers = productVM.getTopSellerProducts(from: allProducts)
            let topSellerIDs = Set(topSellers.compactMap { $0.id })
            let others = allProducts.filter { product in
                guard let id = product.id else { return true }
                return !topSellerIDs.contains(id)
            }

            if allProducts.isEmpty {
                VStack(spacing: 12) {
                    Text("No results found :(")
                        .font(.custom("ReemKufi-Bold", size: 20))
                    Text("Try adjusting your filters or search.")
                        .font(.custom("ReemKufi-Regular", size: 14))
                        .foregroundColor(.gray)

                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Text("Adjust Filters")
                            .padding()
                            .background(maroon)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.custom("ReemKufi-Bold", size: 14))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    if !topSellers.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Top Sellers")
                                .font(.custom("ReemKufi-Bold", size: 20))
                                .foregroundColor(maroon)
                                .padding(.horizontal, 20)
                                .padding(.top, 15)

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(topSellers) { product in
                                    ProductItem(product: product)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                            if !others.isEmpty {
                                Text("More Listings")
                                    .font(.custom("ReemKufi-Bold", size: 20))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(others) { product in
                                        ProductItem(product: product)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(allProducts.sortedByAvailabilityThenDate()) { product in
                                ProductItem(product: product)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            productVM.fetchProducts()
            productVM.fetchSellerRatings()
            categoryViewModel.fetchCategories()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(filters: $localFilters, didApplyFilters: .constant(false))
                .environmentObject(categoryViewModel)
        }
    }

    // MARK: - Filter Chips View
    @ViewBuilder
    private func filterChips() -> some View {
        let chips: [String] = [
            localFilters.gender.map { "[\($0)]" },
            localFilters.condition.map { "[\($0)]" },
            localFilters.size.map { "[Size: \($0)]" },
            localFilters.sortBy.map { "[Sort: \($0)]" },
            localFilters.minPrice != nil || localFilters.maxPrice != nil
                ? "[\(Int(localFilters.minPrice ?? 0)) - \(Int(localFilters.maxPrice ?? 2500)) QAR]"
                : nil,
            localFilters.categoryID.flatMap { id in
                categoryViewModel.categories.first(where: { $0.id == id })?.name
            }.map { "[Category: \($0)]" }
        ].compactMap { $0 }

        if !chips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips, id: \.self) { chip in
                        Text(chip)
                            .font(.custom("ReemKufi-Regular", size: 13))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(maroon.opacity(0.1))
                            .foregroundColor(maroon)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 5)
        }
    }
}
