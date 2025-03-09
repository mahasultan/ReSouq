//
//  BottomBarView.swift
//  ReSouq
//
//
import SwiftUI

struct BottomBarView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                NavigationLink(destination: HomeView()) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                }

                Spacer()

                NavigationLink(destination: LikesView()) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
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
                    .offset(y: -10)
                }

                Spacer()

                NavigationLink(destination: CartView()) {
                    Image(systemName: "cart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                }

                Spacer()

                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .background(
                Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                    .edgesIgnoringSafeArea(.bottom) // ✅ Ensures full coverage
                    .shadow(radius: 3)
            )
        }
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}

