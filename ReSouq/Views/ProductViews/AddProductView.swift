//
//  AddProductView.swift
//  ReSouq
//

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

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // Image Picker
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    if let productImage = productImage {
                        Image(uiImage: productImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.gray, lineWidth: 1)
                                .frame(width: 100, height: 100)
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $productImage)
                }

                // Product Name
                TextField("Product Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Price
                TextField("Price (QAR)", text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Description
                TextEditor(text: $description)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding()

                // Category Picker
                Picker("Select Category", selection: $selectedCategoryID) {
                    Text("Select a category").tag("")
                    ForEach(categoryVM.categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Gender Picker
                Picker("Select Gender", selection: $selectedGender) {
                    Text("Select gender").tag("")
                    ForEach(genderOptions, id: \.self) { gender in
                        Text(gender).tag(gender)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Condition Picker
                Picker("Select Condition", selection: $selectedCondition) {
                    Text("Select condition").tag("")
                    ForEach(conditionOptions, id: \.self) { condition in
                        Text(condition).tag(condition)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Error Message
                if let errorMessage = productVM.errorMessage {
                    Text(errorMessage)
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
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(productVM.isSubmitting)
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Add Product")
            .onAppear {
                categoryVM.fetchCategories()
            }
        }
    }

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

