import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: String?
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var verificationID: String?

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

    func signUp(fullName: String, email: String, password: String, phoneNumber: String?, profileImage: UIImage?, completion: @escaping (Error?) -> Void) {
        guard let phoneNumber = phoneNumber, !phoneNumber.isEmpty else {
            completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Phone number is required."]))
            return
        }
        
        // Ensure phone number is exactly 8 digits
        let phoneRegex = "^[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        if !phonePredicate.evaluate(with: phoneNumber) {
            completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Phone number must be exactly 8 digits."]))
            return
        }

        // Add Qatar country code +974 before storing
        let formattedPhoneNumber = "+974\(phoneNumber)"

        checkPhoneNumberUniqueness(phoneNumber: formattedPhoneNumber) { isUnique in
            if isUnique {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    guard let user = result?.user else {
                        completion(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred."]))
                        return
                    }

                    let userID = user.uid
                    if let image = profileImage {
                        self.uploadProfileImage(userID: userID, image: image) { imageUrl in
                            self.saveUserToFirestore(
                                userID: userID,
                                fullName: fullName,
                                email: email,
                                phoneNumber: formattedPhoneNumber, // Save with country code
                                profileImageURL: imageUrl ?? "",
                                completion: completion
                            )
                        }
                    } else {
                        self.saveUserToFirestore(
                            userID: userID,
                            fullName: fullName,
                            email: email,
                            phoneNumber: formattedPhoneNumber, // Save with country code
                            profileImageURL: "",
                            completion: completion
                        )
                    }
                }
            } else {
                completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Phone number already in use."]))
            }
        }
    }



    // MARK: - Login with Email
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

    // MARK: - Send OTP for Phone Login
    func sendOTP(phoneNumber: String) {
        let formattedPhoneNumber = "+974\(phoneNumber)" // Ensure country code is included
        
        PhoneAuthProvider.provider().verifyPhoneNumber(formattedPhoneNumber, uiDelegate: nil) { verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to send OTP: \(error.localizedDescription)"
                    return
                }
                
                if let verificationID = verificationID {
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    self.verificationID = verificationID
                }
            }
        }
    }


    // MARK: - Verify OTP and Login
    func verifyOTP(otp: String) {
        let savedVerificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        guard let verificationID = savedVerificationID ?? self.verificationID else {
            self.errorMessage = "Verification ID is missing. Please request a new OTP."
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otp
        )

        Auth.auth().signIn(with: credential) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "OTP Verification Failed: \(error.localizedDescription)"
                } else if let user = result?.user {
                    self.isLoggedIn = true
                    self.userID = user.uid
                    self.fetchUserDetails(uid: user.uid)
                }
            }
        }
    }


    // MARK: - Link Phone to Existing Account
    func linkPhoneNumber(verificationID: String, otp: String) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)

        Auth.auth().currentUser?.link(with: credential) { authResult, error in
            if let error = error {
                self.errorMessage = "Failed to link phone number: \(error.localizedDescription)"
            } else {
                self.fetchUserDetails(uid: Auth.auth().currentUser?.uid ?? "")
            }
        }
    }

    // MARK: - Check Phone Number Uniqueness
    private func checkPhoneNumberUniqueness(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking phone uniqueness: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(snapshot?.documents.isEmpty ?? true)
            }
        }
    }

    // MARK: - Save User to Firestore
    private func saveUserToFirestore(userID: String, fullName: String, email: String, phoneNumber: String?, profileImageURL: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "id": userID,
            "fullName": fullName,
            "email": email,
            "phoneNumber": phoneNumber ?? "",
            "profileImageURL": profileImageURL,
            "savedAddresses": [], 
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("users").document(userID).setData(userData) { error in
            completion(error)  
        }
    }

    // MARK: - Fetch User Details
    func fetchUserDetails(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async { self.user = nil }
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                DispatchQueue.main.async { self.user = nil }
                return
            }

            do {
                let userData = try snapshot.data(as: User.self)
                DispatchQueue.main.async { self.user = userData }
            } catch {
                DispatchQueue.main.async { self.user = nil }
            }
        }
    }

    // MARK: - Upload Profile Image
    func uploadProfileImage(userID: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get image URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    func updateUserProfile(fullName: String, phoneNumber: String, email: String, completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found")
            completion()
            return
        }

        let userRef = Firestore.firestore().collection("users").document(userID)

        userRef.updateData([
            "fullName": fullName,
            "phoneNumber": phoneNumber,
            "email": email
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully")

                    // Update local user object to reflect changes immediately
                    self.user?.fullName = fullName
                    self.user?.phoneNumber = phoneNumber
                    self.user?.email = email
                }
                completion() // Ensure the completion handler is always called
            }
        }
    }


    func saveShippingAddress(_ address: String) {
        guard let userID = self.user?.id else { return }
        let userRef = Firestore.firestore().collection("users").document(userID)

        var updatedAddresses = self.user?.savedAddresses ?? []
        
        if !updatedAddresses.contains(address) { // Prevent duplicate addresses
            updatedAddresses.append(address)
            userRef.updateData(["savedAddresses": updatedAddresses]) { error in
                if let error = error {
                    print("Error saving shipping address: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.user?.savedAddresses = updatedAddresses
                    }
                    print("Shipping address saved successfully!")
                }
            }
        }
    }
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.userID = nil
                self.user = nil
            }
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}
