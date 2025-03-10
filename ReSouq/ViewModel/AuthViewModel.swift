//
//  AuthViewModel.swift
//  ReSouq
//
//

//
//  AuthViewModel.swift
//  ReSouq
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: String?
    @Published var user: User?
    @Published var errorMessage: String?

    let db = Firestore.firestore()

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.isLoggedIn = (user != nil)
                self.userID = user?.uid
                if let uid = user?.uid {
                    self.fetchUserDetails(uid: uid)
                }
            }
        }
    }

    func getCurrentUserID() -> String? {
        return userID
    }

    func signUp(fullName: String, email: String, password: String, phoneNumber: String?, profileImage: UIImage?) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                return
            }

            guard let user = result?.user else { return }
            let userID = user.uid


            if let image = profileImage {

                // Upload image before saving user data
                self.uploadProfileImage(userID: userID, image: image) { imageUrl in
                    if let imageUrl = imageUrl {
                        
                    } else {                    }

                    // Save user data to Firestore with the image URL
                    self.saveUserToFirestore(userID: userID, fullName: fullName, email: email, phoneNumber: phoneNumber, profileImageURL: imageUrl ?? "")
                }
            } else {
                self.saveUserToFirestore(userID: userID, fullName: fullName, email: email, phoneNumber: phoneNumber, profileImageURL: "")
            }
        }
    }



    private func saveUserToFirestore(userID: String, fullName: String, email: String, phoneNumber: String?, profileImageURL: String) {
        let userData: [String: Any] = [
            "id": userID,
            "fullName": fullName,
            "email": email,
            "phoneNumber": phoneNumber ?? "",
            "profileImageURL": profileImageURL,
            "createdAt": Timestamp(date: Date())
        ]


        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
            } else {
                self.fetchUserDetails(uid: userID)
            }
        }
    }

    func uploadProfileImage(userID: String, image: UIImage, completion: @escaping (String?) -> Void) {

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil)
                return
            }


            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(nil)
                } else if let imageUrl = url?.absoluteString {
                    completion(imageUrl)
                }
            }
        }
    }

    func fetchUserDetails(uid: String) {

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }

            do {
                let userData = try snapshot.data(as: User.self)
                DispatchQueue.main.async {
                    self.user = userData
                }
            } catch {
                DispatchQueue.main.async {
                    self.user = nil
                }
            }
        }
    }



    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Login Failed: \(error.localizedDescription)"
                    self.isLoggedIn = false
                    self.user = nil
                } else if let user = result?.user { 
                    self.isLoggedIn = true
                    self.userID = user.uid
                    self.fetchUserDetails(uid: user.uid)
                }
            }
        }
    }



    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.userID = nil
                self.user = nil
            }
        } catch let signOutError {
        }
    }
}



