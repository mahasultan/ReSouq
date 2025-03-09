//
//  SplashView.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 03/03/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 1.0 
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                .ignoresSafeArea()

            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 310, height: 300)
                .scaleEffect(scaleEffect)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        scaleEffect = 1.2
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}


