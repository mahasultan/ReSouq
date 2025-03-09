//
//  HomeView.swift
//  ReSouq
//
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TopBarView(showLogoutButton: true, showAddButton: true)
                        .environmentObject(authViewModel)

                    Spacer()
                }

                VStack {
                    Spacer()
                    BottomBarView()
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
    }
}
