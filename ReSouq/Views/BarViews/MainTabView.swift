//
//  MainTabView.swift
//  ReSouq
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
                            .frame(width: 24, height: 24)
                        Text("Home")
                    }

                LikesView()
                    .tag("Likes")
                    .tabItem {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text("Likes")
                    }

                AddProductView()
                    .tag("AddProduct")
                    .tabItem { Label("Add", systemImage: "plus.circle.fill") }

                CartView()
                    .tag("Cart")
                    .tabItem {
                        ZStack {
                            if !cartViewModel.cart.products.isEmpty {
                                ZStack {
                                    Image(systemName: "cart.fill")
                                        .font(.system(size: 22))

                                    ZStack {
                                        Text("\(cartViewModel.cart.products.count)")
                                            .font(.caption2)
                                            .bold()
                                    }
                                }
                            } else {
                                Image(systemName: "cart.fill")
                                Text("Cart")
                            }
                        }
                    }

                if authViewModel.user != nil {
                    ProfileView()
                        .tag("Profile")
                        .tabItem {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("Profile")
                        }
                } else {
                    GuestProfileView()
                        .tag("GuestProfile")
                        .tabItem {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("Profile")
                        }
                }
            }
            .accentColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
            .onAppear {
                UITabBar.appearance().unselectedItemTintColor = UIColor.black //
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
