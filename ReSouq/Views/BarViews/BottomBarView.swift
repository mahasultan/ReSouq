//
//  BottomBarView.swift
//  ReSouq
//
//
import SwiftUI

struct BottomBarView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: HomeView()) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: LikesView()) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: AddProductView()) {
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
                                        
                    NavigationLink(destination: CartView()) {
                        ZStack {
                            Image(systemName: "cart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(.black)
                            
                            
                            if cartViewModel.cart.products.count > 0 {
                                Text("\(cartViewModel.cart.products.count)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                            }}}
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: 60)

                Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                    .frame(height: 15)
            }
            .background(
                Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                    .shadow(radius: 3)
            )
            .ignoresSafeArea(.all, edges: .bottom) 
        }
    }
}

// Preview
struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}

