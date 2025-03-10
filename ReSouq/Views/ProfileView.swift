//
//  ProfileView.swift
//  ReSouq
//
//
import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
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
                }
                Text(user.fullName)
                    .font(.title)
                    .bold()
                Text(user.email)
                    .foregroundColor(.gray)
                Text(user.phoneNumber ?? "No phone number")
                    .foregroundColor(.gray)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if let userID = authViewModel.getCurrentUserID() {
                authViewModel.fetchUserDetails(uid: userID)
            }
        }
    }
}




#Preview {
    ProfileView()
}
