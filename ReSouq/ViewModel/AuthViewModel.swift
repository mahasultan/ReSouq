//
//  AuthViewModel.swift
//  ReSouq
//
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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

    func signUp(fullName: String, email: String, password: String, phoneNumber: String?) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign-Up Failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                let userData: [String: Any] = [
                    "id": user.uid,
                    "fullName": fullName,
                    "email": email,
                    "phoneNumber": phoneNumber ?? "",
                    "profileImageURL": "",
                    "location": "",
                    "createdAt": Timestamp(date: Date())
                ]

                print("Writing to Firestore: \(userData)")
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("Firestore Save Error: \(error.localizedDescription)")
                    } else {
                        print("User Successfully Saved in Firestore: \(userData)")
                    }
                }
            }
        }
    }


    func fetchUserDetails(uid: String) {
        print("Fetching user data from Firestore...")

        db.collection("users").document(uid).getDocument { snapshot, error in
            print("Firestore callback triggered.")

            if let error = error {
                print("Firestore fetch error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                print("No user data found in Firestore for UID: \(uid)")
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }

            do {
                let userData = try snapshot.data(as: User.self)
                print("Firestore Data Retrieved: \(userData)")
                DispatchQueue.main.async {
                    self.user = userData
                }
            } catch {
                print("Firestore Decoding Error: \(error.localizedDescription)")
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
                    print("Login successful for: \(user.email ?? "")")
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
            print("User logged out successfully.")
        } catch let signOutError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}



