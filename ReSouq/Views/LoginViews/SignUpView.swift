//
//  SignUpView.swift
//  ReSouq
//


import SwiftUI
import Firebase
import FirebaseAuth
import UIKit

struct SignUpView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @State private var profileImage: UIImage?
    @State private var isImagePickerPresented = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer(minLength: 40)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Create\nAccount")
                        .font(.custom("ReemKufi-Bold", size: 50))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .overlay(
                Image("recycle_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 270)
                    .offset(x: 160, y: 60)
            )
            
            Spacer(minLength: 10)
            
            TextField("Full Name", text: $fullName)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
                .padding(.horizontal, 30)

            TextField("Email", text: $email)
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
                .padding(.horizontal, 30)

            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 1)
            .padding(.horizontal, 30)

            HStack {
                Text("🇶🇦")
                    .frame(width: 80, height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)

                TextField("Your number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 5)
            }
            
            Button(action: {
                errorMessage = nil
                
                guard !fullName.isEmpty else {
                    errorMessage = "Full name is required."
                    return
                }
                guard !email.isEmpty else {
                    errorMessage = "Email is required."
                    return
                }
                guard !password.isEmpty else {
                    errorMessage = "Password is required."
                    return
                }
                guard !phoneNumber.isEmpty else {
                    errorMessage = "Phone number is required."
                    return
                }

                authViewModel.signUp(
                    fullName: fullName,
                    email: email,
                    password: password,
                    phoneNumber: phoneNumber,
                    profileImage: profileImage
                ) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    }
                }

            }) {
                Text("Done")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 30)
            }
            .padding(.top, 10)

            NavigationLink(destination: LoginView()) {
                Text("Cancel")
                    .foregroundColor(.black)
            }
            .padding(.top, 10)
            .navigationBarBackButtonHidden(true)

            Spacer()
        }
        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
    }
}
