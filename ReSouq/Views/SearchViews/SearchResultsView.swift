import SwiftUI

struct SearchResultsView: View {
    var searchQuery: String
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    let columns = [
        GridItem(.flexible(), spacing: 40),
        GridItem(.flexible(), spacing: 40)
    ]

    var body: some View {
        VStack {
            Text("Search Results for '\(searchQuery)'")
                .font(.custom("ReemKufi-Bold", size: 22))
                .padding(.top, 10)

            let filteredProducts = productVM.products.filter {
                $0.name.lowercased().contains(searchQuery.lowercased())
            }

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
            categoryViewModel.fetchCategories()
        }
    }
}
