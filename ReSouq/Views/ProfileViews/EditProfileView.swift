//
//  EditProfileView.swift
//  ReSouq
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var isSaving = false

    // App colors
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Deep Red
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)) // Beige
    private let textColor = Color.black
    private let secondaryTextColor = Color.gray

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.custom("ReemKufi-Bold", size: 24))
                .foregroundColor(buttonColor)
                .padding()

            TextField("Full Name", text: $fullName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                isSaving = true
                authViewModel.updateUserProfile(fullName: fullName, phoneNumber: phoneNumber, email: email) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSaving = false
                        presentationMode.wrappedValue.dismiss() //  Go back to ProfileView after saving
                    }
                }
            }) {
                HStack {
                    if isSaving {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save Changes")
                            .font(.custom("ReemKufi-Bold", size: 18))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(buttonColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(isSaving)


            Spacer()
        }
        .background(backgroundColor.ignoresSafeArea()) // Set background color
        .onAppear {
            if let user = authViewModel.user {
                self.fullName = user.fullName
                self.phoneNumber = user.phoneNumber ?? ""
                self.email = user.email
            }
        }
    }
}

//Preview
#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
