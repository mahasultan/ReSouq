//
//  ProfileView.swift
//  ReSouq
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoggedOut = false


    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    authViewModel.logout()
                    isLoggedOut = true
                }) {
                    Image(systemName: "arrow.backward.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.red)
                }
                .padding(.trailing, 20)
            }

            if let user = authViewModel.user {
                if let imageUrl = user.profileImageURL, !imageUrl.isEmpty {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }

                VStack(spacing: 5) {
                    Text(user.fullName)
                        .font(.title)
                        .bold()

                    Text(user.email)
                        .foregroundColor(.gray)

                    if let phone = user.phoneNumber, !phone.isEmpty {
                        Text(phone)
                            .foregroundColor(.gray)
                    } else {
                        Text("No phone number")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 10)

            } else {
                ProgressView()
                    .onAppear {
                        if let userID = authViewModel.getCurrentUserID() {
                            authViewModel.fetchUserDetails(uid: userID)
                        }
                    }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
