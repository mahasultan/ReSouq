//
//  LoginView.swift
//  ReSouq
//

import SwiftUI

struct LoginView: View {
    @State private var identifier: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible = false
    @State private var isUsingPhoneLogin = false
    @State private var otpCode: String = ""
    @State private var showOTPField = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Spacer(minLength: 40)

                // Title
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome\nBack")
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

                // Toggle between Email/Phone login
                Picker("", selection: $isUsingPhoneLogin) {
                    Text("Email").tag(false)
                    Text("Phone").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 30)

                // Email or Phone Input
                VStack(alignment: .leading) {
                    if isUsingPhoneLogin {
                        TextField("Enter your phone number", text: $identifier)
                            .keyboardType(.phonePad)
                    } else {
                        TextField("Enter your email", text: $identifier)
                            .keyboardType(.emailAddress)
                    }
                }
                .padding()
                .frame(height: 50)
                .background(Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)))
                .cornerRadius(20)
                .shadow(radius: 1)
                .padding(.horizontal, 30)

                // Password or OTP Input
                if isUsingPhoneLogin {
                    if showOTPField {
                        TextField("Enter OTP", text: $otpCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(height: 50)
                            .background(Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)))
                            .cornerRadius(20)
                            .shadow(radius: 1)
                            .padding(.horizontal, 30)
                    }
                } else {
                    VStack(alignment: .leading) {
                        HStack {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
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
                        .background(Color(UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)))
                        .cornerRadius(20)
                        .shadow(radius: 1)
                    }
                    .padding(.horizontal, 30)
                }

                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 5)
                }

                // Login Button
                Button(action: {
                    if isUsingPhoneLogin {
                        if showOTPField {
                            authViewModel.verifyOTP(otp: otpCode)
                        } else {
                            authViewModel.sendOTP(phoneNumber: identifier)
                            showOTPField = true
                        }
                    } else {
                        authViewModel.login(email: identifier, password: password)
                    }
                }) {
                    Text(isUsingPhoneLogin && !showOTPField ? "Send OTP" : "Login")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 10)

                // Sign-Up Navigation
                HStack {
                    Text("I don’t have an account")
                        .foregroundColor(.black)
                    NavigationLink(destination: SignUpView()) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                    }
                }
                .padding(.top, 10)

                Spacer()
            }
            .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthViewModel())
    }
}
