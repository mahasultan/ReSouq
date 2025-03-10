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
            
            // 📌 Profile Image Picker
            HStack {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)), lineWidth: 2))
                            .clipped()
                    } else {
                        ZStack {
                            Circle()
                                .strokeBorder(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)), lineWidth: 2)
                                .frame(width: 80, height: 80)
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                        }
                    }
                }
                .sheet(isPresented: $isImagePickerPresented, content: {
                    ImagePicker(selectedImage: $profileImage)
                })
                
                Spacer()
            }
            .padding(.horizontal, 30)
            
            // 📌 Full Name Input
            VStack(alignment: .leading) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)
            
            // 📌 Email Input Field
            VStack(alignment: .leading) {
                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)
            
            // 📌 Password Input Field
            VStack(alignment: .leading) {
                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
            }
            .padding(.horizontal, 30)
            
            HStack {
                Text("🇶🇦")
                    .frame(width: 80, height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)

                TextField("Your number", text: $phoneNumber)
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
                authViewModel.signUp(
                    fullName: fullName,
                    email: email,
                    password: password,
                    phoneNumber: phoneNumber,
                    profileImage: profileImage
                )
            }) {
                Text("Done")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))) // 691616
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 30)
            }
            .padding(.top, 10)
            
            Button(action: {
            }) {
                NavigationLink(destination: LoginView()) {
                    Text("Cancel")
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 10)
            .navigationBarBackButtonHidden(true)
            
            Spacer()
        }
        .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
    }
}
