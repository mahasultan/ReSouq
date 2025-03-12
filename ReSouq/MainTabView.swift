//
//  MainTabView.swift
//  ReSouq
//
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 0) {

            TabView(selection: $navigationManager.currentPage) {
                HomeView()
                    .tag("Home")
                    .tabItem { Label("Home", systemImage: "house.fill") }

                LikesView()
                    .tag("Likes")
                    .tabItem { Label("Likes", systemImage: "heart.fill") }

                AddProductView()
                    .tag("AddProduct")
                    .tabItem { Label("Add", systemImage: "plus.circle.fill") }
                    .frame(width: 24, height: 24) // Standard size


                CartView()
                    .tag("Cart")
                    .tabItem {
                        Label("Cart", systemImage: "cart.fill")
                            .overlay(
                                cartViewModel.cart.products.count > 0 ?
                                Text("\(cartViewModel.cart.products.count)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                                : nil
                            )
                    }

                ProfileView()
                    .tag("Profile")
                    .tabItem { Label("Profile", systemImage: "person.fill") }
            }
            .accentColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
            .onAppear {
                UITabBar.appearance().unselectedItemTintColor = UIColor.black
            }        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
