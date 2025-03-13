//
//  ProfileView.swift
//  ReSouq
//
import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoggedOut = false

    // App Colors
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Dark Red
    private let textColor = Color.black
    private let secondaryTextColor = Color.gray

    var body: some View {
        VStack {
            // Top Bar with Logout Button on Right
            ZStack {
                TopBarView(showLogoutButton: false, showAddButton: false)

                HStack {
                    Spacer()

                    Button(action: {
                        authViewModel.logout()
                        isLoggedOut = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(buttonColor)
                    }
                    .padding(.trailing, 20)
                }
            }

            Spacer()

            if let user = authViewModel.user {
                VStack(spacing: 15) {
                    // Profile Image
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
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }

                    // User Info
                    VStack(spacing: 5) {
                        Text(user.fullName)
                            .font(.custom("ReemKufi-Bold", size: 22))
                            .foregroundColor(textColor)

                        Text(user.email)
                            .font(.custom("ReemKufi-Bold", size: 18))
                            .foregroundColor(secondaryTextColor)

                        if let phone = user.phoneNumber, !phone.isEmpty {
                            Text(phone)
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .foregroundColor(secondaryTextColor)
                        } else {
                            Text("No phone number")
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    .padding(.top, 5)
                }
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
        .background(Color.white.ignoresSafeArea())
    }
}

// Preview
#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
