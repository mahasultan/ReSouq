import SwiftUI
import FirebaseFirestore

struct AddProductView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var categoryVM = CategoryViewModel()
    @StateObject var productVM = ProductViewModel()
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

    // App Colors
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)) // Beige
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Dark Red
    private let textFieldBorderColor = Color.gray.opacity(0.5)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // Title
                    Text("Add Product")
                        .font(.custom("ReemKufi-Bold", size: 30))
                        .foregroundColor(buttonColor)
                        .padding(.top, 10)
                    
                    // Image Picker
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
                                    .background(Color.white.opacity(0.3))
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

                    // Form Fields
                    VStack(spacing: 15) {
                        CustomTextField(placeholder: "Product Name", text: $name)
                        CustomTextField(placeholder: "Price (QAR)", text: $price, keyboardType: .decimalPad)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(textFieldBorderColor, lineWidth: 1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .font(.custom("ReemKufi-Bold", size: 18))

                        // Category Picker
                        CustomPicker(title: "Select Category", selection: $selectedCategoryID, options: categoryVM.categories.map { ($0.name, $0.id) })

                        // Gender Picker
                        CustomPicker(title: "Select Gender", selection: $selectedGender, options: genderOptions.map { ($0, $0) })

                        // Condition Picker
                        CustomPicker(title: "Select Condition", selection: $selectedCondition, options: conditionOptions.map { ($0, $0) })
                    }

                    // Error Message
                    if let errorMessage = productVM.errorMessage {
                        Text(errorMessage)
                            .font(.custom("ReemKufi-Bold", size: 18))
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Submit Button
                    Button(action: addProduct) {
                        if productVM.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Add Product")
                                .font(.custom("ReemKufi-Bold", size: 20))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        }
                    }
                    .disabled(productVM.isSubmitting)
                    .padding()

                    Spacer()
                }
                .padding()
            }
            .background(backgroundColor.ignoresSafeArea())
            .onAppear {
                categoryVM.fetchCategories()
            }
        }
    }

    // Submit function
    private func addProduct() {
        guard let userID = authViewModel.userID,
              !name.isEmpty,
              let priceValue = Double(price),
              !selectedCategoryID.isEmpty,
              !selectedGender.isEmpty,
              !selectedCondition.isEmpty else {
            productVM.errorMessage = "Please fill in all fields."
            return
        }

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
            if success {
                print("Product added successfully")
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
            .background(Color.white.opacity(0.8))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(textFieldBorderColor, lineWidth: 1))
            .cornerRadius(10)
            .keyboardType(keyboardType)
            .padding(.horizontal)
            .font(.custom("ReemKufi-Bold", size: 18))
    }
}

// Custom Picker
struct CustomPicker: View {
    var title: String
    @Binding var selection: String
    var options: [(label: String, value: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.custom("ReemKufi-Bold", size: 18))
                .foregroundColor(.gray)
                .padding(.leading, 15)
            
            Picker(title, selection: $selection) {
                Text("Select an option").tag("")
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            .font(.custom("ReemKufi-Bold", size: 18))
        }
    }
}
