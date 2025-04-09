import SwiftUI

struct CategoryProductsView: View {
    var categoryID: String
    var categoryName: String
    @StateObject var productVM = ProductViewModel()
    @StateObject var categoryViewModel = CategoryViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 50),
        GridItem(.flexible(), spacing: 50)
    ]

    private let maroon = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(categoryName) Products")
                .font(.custom("ReemKufi-Bold", size: 22))
                .padding(.top, 10)
                .padding(.horizontal)

            let allProducts = productVM
                .getProducts(categoryID: categoryID, categories: categoryViewModel.categories)

            let topSellers = productVM.getTopSellerProducts(from: allProducts)
            let topSellerIDs = Set(topSellers.compactMap { $0.id })
            let others = allProducts.filter { product in
                guard let id = product.id else { return true }
                return !topSellerIDs.contains(id)
            }.sortedByAvailabilityThenDate()

            if allProducts.isEmpty {
                Text("No products found.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    if !topSellers.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Top Sellers")
                                .font(.custom("ReemKufi-Bold", size: 20))
                                .foregroundColor(maroon)
                                .padding(.horizontal, 25)
                                .padding(.top, 10)

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(topSellers) { product in
                                    ProductItem(product: product)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 25)

                            if !others.isEmpty {
                                Text("More Listings")
                                    .font(.custom("ReemKufi-Bold", size: 20))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 25)
                                    .padding(.top, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(others) { product in
                                        ProductItem(product: product)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.bottom, 25)
                            }
                        }
                    } else {
                        // Show all normally if no top sellers
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(allProducts.sortedByAvailabilityThenDate()) { product in
                                ProductItem(product: product)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 25)
                    }
                }
            }
        }
        .onAppear {
            productVM.fetchProducts()
            productVM.fetchSellerRatings()
            categoryViewModel.fetchCategories()
        }
    }
}
