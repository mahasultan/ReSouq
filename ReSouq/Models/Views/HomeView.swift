//
//  HomeView.swift
//  ReSouq
//
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var productVM = ProductViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TopBarView(showLogoutButton: true, showAddButton: true)
                        .environmentObject(authViewModel)

                    VStack(alignment: .leading) {
                        Text("New Listings")
                            .font(.custom("ReemKufi-Bold", size: 22))
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                if productVM.products.isEmpty {
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

                    Spacer()
                }

                VStack {
                    Spacer()
                    BottomBarView()
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .onAppear {
                productVM.fetchProducts()
            }
        }
    }
}


// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(ProductViewModel())
    }
}
