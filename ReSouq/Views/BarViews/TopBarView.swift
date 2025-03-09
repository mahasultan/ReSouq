//
//  TopBarView.swift
//  ReSouq
//
//
import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var showLogoutButton: Bool
    var showAddButton: Bool

    var body: some View {
        ZStack {
            Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                .ignoresSafeArea(edges: .top)
                .frame(height: 50)
                .shadow(radius: 3)

            HStack {
                Image("Logo-2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .padding(.leading, 10)
                    .padding(.top, -10)

                Spacer()

                if showLogoutButton {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Image(systemName: "arrow.backward.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 50)
        }
        .frame(height: 50)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(showLogoutButton: true, showAddButton: true)
            .environmentObject(AuthViewModel())
    }
}
