//
//  SignUpView.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 09/03/2025.
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
    @State private var selectedCountry: String = "🇶🇦"
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
            
            // Full Name Input
            VStack(alignment: .leading) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
                
            }.padding(.horizontal, 30)
            
            // Email Input Field
            VStack(alignment: .leading) {
                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)
            
            // Password Input Field
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
            
            // Phone Number Input with Country Flag Picker
            HStack {
                Menu {
                    Button(action: { selectedCountry = "🇶🇦" }) { Text("🇶🇦 Qatar") }
                    Button(action: { selectedCountry = "🇸🇦" }) { Text("🇸🇦 Saudi Arabia") }
                    Button(action: { selectedCountry = "🇦🇪" }) { Text("🇦🇪 UAE") }
                    Button(action: { selectedCountry = "🇰🇼" }) { Text("🇰🇼 Kuwait") }
                    Button(action: { selectedCountry = "🇧🇭" }) { Text("🇧🇭 Bahrain") }
                    Button(action: { selectedCountry = "🇴🇲" }) { Text("🇴🇲 Oman") }
                } label: {
                    HStack {
                        Text(selectedCountry)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                }
                .frame(width: 65, height: 50)
                .background(Color.white)
                .cornerRadius(20)
                
                TextField("Your number", text: $phoneNumber)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
            .padding(.horizontal, 30)
            
            // Error Message Display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 5)
            }
            
            // Sign-Up Button
            Button(action: {
                signUpUser()
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
            
            // Cancel Button
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
    
    // Image Picker for Profile Picture Selection
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary // Opens photo gallery
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image // Assign selected image
                }
                picker.dismiss(animated: true)
            }
        }
    }
    
    // Firebase Sign-Up Function
    func signUpUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Sign-Up Failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let user = result?.user else {
                print("⚠️ User is nil after sign-up.")
                return
            }
            
            print("✅ User signed up successfully: \(user.email ?? "")")
            
            // Store user data in Firestore
            let userData: [String: Any] = [
                "id": user.uid,
                "fullName": fullName,
                "email": email,
                "phoneNumber": phoneNumber,
                "profileImageURL": "",
                "location": "",
                "createdAt": Timestamp(date: Date())
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("❌ Firestore Save Failed: \(error.localizedDescription)")
                } else {
                    print("✅ User data saved in Firestore - User ID: \(user.uid)")
                    DispatchQueue.main.async {
                        authViewModel.isLoggedIn = true // Automatically log in
                    }
                }
            }
        }
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
