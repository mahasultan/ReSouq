import SwiftUI
import FirebaseFirestore

struct AddProductView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var categoryVM = CategoryViewModel()
    @StateObject var productVM = ProductViewModel()
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var selectedCategoryID = ""
    @State private var selectedGender = ""
    @State private var selectedCondition = ""
    @State private var productImage: UIImage?
    @State private var isImagePickerPresented = false
    
    private let genderOptions = ["Female", "Male", "Unisex"]
    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textFieldBorderColor = Color.gray.opacity(0.5)
    
    var body: some View {
        NavigationStack {
            VStack {
                // Top Bar
                TopBarView(showLogoutButton: false, showAddButton: false)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Add Product")
                            .font(.custom("ReemKufi-Bold", size: 30))
                            .foregroundColor(buttonColor)
                            .padding(.leading, 15)
                            .padding(.top, 10)
                        
                        // Image Picker
                        HStack {
                            Spacer()
                            Button(action: {
                                isImagePickerPresented = true
                            }) {
                                if let productImage = productImage {
                                    Image(uiImage: productImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                            .frame(width: 150, height: 150)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        Image(systemName: "camera.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .sheet(isPresented: $isImagePickerPresented) {
                                ImagePicker(selectedImage: $productImage)
                            }
                            Spacer()
                        }
                        
                        // Form Fields
                        VStack(spacing: 15) {
                            CustomTextField(placeholder: "Product Name", text: $name)
                                .font(.system(size: 18))
                            CustomTextField(placeholder: "Price (QAR)", text: $price, keyboardType: .decimalPad)
                                .font(.system(size: 18))
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding()
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(textFieldBorderColor, lineWidth: 1))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            
                            // Category Picker
                            CustomDropdownPicker(title: "Select Category", selection: $selectedCategoryID, options: categoryVM.categories.map { ($0.name, $0.id) })
                            
                            // Gender Picker
                            CustomDropdownPicker(title: "Select Gender", selection: $selectedGender, options: genderOptions.map { ($0, $0) })
                            
                            // Condition Picker
                            CustomDropdownPicker(title: "Select Condition", selection: $selectedCondition, options: conditionOptions.map { ($0, $0) })
                        }
                        
                        // Error Message
                        if let errorMessage = productVM.errorMessage {
                            Text(errorMessage)
                                .font(.custom("ReemKufi-Bold", size: 14))
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Submit Button
                        Button(action: addProduct) {
                            if productVM.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Add Product")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor)
                                    .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(productVM.isSubmitting)
                        .padding()
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                categoryVM.fetchCategories()
            }
        }
    }
    
    // Submit function
    private func addProduct() {
        guard let userID = authViewModel.userID,
              !name.trimmingCharacters(in: .whitespaces).isEmpty,
              let priceValue = Double(price.trimmingCharacters(in: .whitespacesAndNewlines)),
              !selectedCategoryID.isEmpty,
              !selectedGender.isEmpty,
              !selectedCondition.isEmpty else {
            productVM.errorMessage = "Please fill in all fields."
            return
        }
        
        productVM.isSubmitting = true // Prevent multiple taps
        
        productVM.saveProduct(
            userID: userID,
            name: name,
            price: priceValue,
            description: description,
            categoryID: selectedCategoryID,
            gender: selectedGender,
            condition: selectedCondition,
            image: productImage
        ) { success in
            DispatchQueue.main.async {
                productVM.isSubmitting = false
                if success {
                    navigationManager.currentPage = "Home" // Navigate to home
                }
            }
        }
    }
}

// MARK: - Custom Components

// Custom TextField
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    private let textFieldBorderColor = Color.gray.opacity(0.5)

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(textFieldBorderColor, lineWidth: 1))
            .cornerRadius(10)
            .keyboardType(keyboardType)
            .padding(.horizontal)
            .font(.custom("ReemKufi-Bold", size: 18))
    }
}

struct CustomDropdownPicker: View {
    var title: String
    @Binding var selection: String
    var options: [(label: String, value: String)]
    @State private var isExpanded = false

    private let borderColor = Color.gray.opacity(0.5)
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.custom("ReemKufi-Bold", size: 18))
                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                .padding(.leading, 15)

            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selection.isEmpty ? "Select an option" : options.first(where: { $0.value == selection })?.label ?? "Select an option")
                        .foregroundColor(selection.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            if isExpanded {
                VStack(spacing: 5) {
                    ForEach(options, id: \.value) { option in
                        Button(action: {
                            selection = option.value
                            isExpanded = false
                        }) {
                            Text(option.label)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selection == option.value ? buttonColor.opacity(0.2) : Color.white)
                                .foregroundColor(.black)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}
