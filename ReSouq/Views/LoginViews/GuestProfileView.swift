//
//  GuestProfileView.swift
//  ReSouq
//
//

import SwiftUI

struct GuestProfileView: View {
    var body: some View {
        VStack(spacing: 0) {
            TopBarView(showLogoutButton: false, showAddButton: false)

            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Text("You are currently browsing as a guest.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("Sign up or log in to access your profile, saved items, and more!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 40)

                VStack(spacing: 12) {
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) // Maroon
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 30)
                    }

                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .font(.system(size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .padding(.horizontal, 30)
                    }
                }
            }
            .padding(.bottom, 40)

            Spacer()

        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }
}

struct GuestProfileView_Previews: PreviewProvider {
    static var previews: some View {
        GuestProfileView()
    }
}
