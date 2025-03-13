//
//  BottomBarView.swift
//  ReSouq
//

import SwiftUI

struct BottomBarView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Faint Line (Divider)
            Divider()
                .background(Color.gray.opacity(0.3)) // Adjust opacity for faintness
                .frame(height: 1) // Adjust height for thickness

            HStack {
                Spacer()

                // Home Button
                bottomBarButton(icon: "house.fill", label: "Home", page: "Home")

                Spacer()

                // Likes Button
                bottomBarButton(icon: "heart.fill", label: "Likes", page: "Likes")

                Spacer()

                Button(action: {
                    if navigationManager.currentPage != "AddProduct" {
                        navigationManager.currentPage = "AddProduct"
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) // Dark red
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)

                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                    .offset(y: -12)
                }

                Spacer()

                // Cart Button
                bottomBarButton(icon: "cart.fill", label: "Cart", page: "Cart")
 

                Spacer()
                // Profile Button
                bottomBarButton(icon: "person.fill", label: "Profile", page: "Profile")

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))) // Beige Background

            Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                .frame(height: 15)
        }
        .background(
            Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func bottomBarButton(icon: String, label: String, page: String) -> some View {
        Button(action: {
            if navigationManager.currentPage != page {
                navigationManager.currentPage = page
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(navigationManager.currentPage == page ? Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) : .gray)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(navigationManager.currentPage == page ? Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) : .gray)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// Preview
struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
            .environmentObject(NavigationManager())
            .environmentObject(CartViewModel())
    }
}
                    
