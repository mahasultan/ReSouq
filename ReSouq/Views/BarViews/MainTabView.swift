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
                    .tabItem {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Standard size
                        Text("Home")
                    }

                LikesView()
                    .tag("Likes")
                    .tabItem {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Standard size
                        Text("Likes")
                    }

                AddProductView()
                    .tag("AddProduct")
                    .tabItem { Label("Add", systemImage: "plus.circle.fill") }

                CartView()
                    .tag("Cart")
                    .tabItem {
                        Image(systemName: "cart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Standard size
                        Text("Cart")
                    }

                ProfileView()
                    .tag("Profile")
                    .tabItem {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Standard size
                        Text("Profile")
                    }
            }
            .accentColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) // ✅ Active tab is Maroon
            .onAppear {
                UITabBar.appearance().unselectedItemTintColor = UIColor.black // ✅ Default icons are black
            }
        }
        .edgesIgnoringSafeArea(.bottom) // ✅ Ensures full coverage
    }
}

