//
//  EditProductView.swift
//  ReSouq
//
//

import SwiftUI
import FirebaseFirestore

struct EditProductView: View {
    var product: Product

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var categoryVM = CategoryViewModel()
    @StateObject var productVM = ProductViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var price: String
    @State private var description: String
    @State private var selectedCategoryID: String
    @State private var selectedGender: String
    @State private var selectedCondition: String
    @State private var productImage: UIImage?
    @State private var isImagePickerPresented = false

    private let genderOptions = ["Female", "Male", "Unisex"]
    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

    init(product: Product) {
        self.product = product
        _name = State(initialValue: product.name)
        _price = State(initialValue: String(format: "%.2f", product.price))
        _description = State(initialValue: product.description)
        _selectedCategoryID = State(initialValue: product.categoryID)
        _selectedGender = State(initialValue: product.gender)
        _selectedCondition = State(initialValue: product.condition)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Edit Product")
                            .font(.custom("ReemKufi-Bold", size: 30))
                            .foregroundColor(buttonColor)
                            .padding(.top, 10)

                        // Image Picker
                        HStack {
                            Spacer()
                            Button(action: { isImagePickerPresented = true }) {
                                if let productImage = productImage {
                                    Image(uiImage: productImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                            .sheet(isPresented: $isImagePickerPresented) {
                                ImagePicker(selectedImage: $productImage)
                            }
                            Spacer()
                        }

                        // Form Fields
                        CustomTextField(placeholder: "Product Name", text: $name)
                            .font(.system(size: 18))
                        CustomTextField(placeholder: "Price (QAR)", text: $price, keyboardType: .decimalPad)
                            .font(.system(size: 18))

                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding()
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(10)
                            .padding(.horizontal)

                        CustomDropdownPicker(title: "Select Category", selection: $selectedCategoryID, options: categoryVM.categories.map { ($0.name, $0.id) })

                        CustomDropdownPicker(title: "Select Gender", selection: $selectedGender, options: genderOptions.map { ($0, $0) })

                        CustomDropdownPicker(title: "Select Condition", selection: $selectedCondition, options: conditionOptions.map { ($0, $0) })

                        // Submit Button
                        Button(action: updateProduct) {
                            Text("Update Product")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(productVM.isSubmitting)
                        .padding()
                    }
                    .padding()
                }
            }
            .onAppear {
                categoryVM.fetchCategories()
            }
        }
    }

    private func updateProduct() {
        var updatedProduct = product
        updatedProduct.name = name
        updatedProduct.price = Double(price) ?? product.price
        updatedProduct.description = description
        updatedProduct.categoryID = selectedCategoryID
        updatedProduct.gender = selectedGender
        updatedProduct.condition = selectedCondition

        productVM.updateProduct(productID: product.id!, updatedProduct: updatedProduct, newImage: productImage) {
            dismiss()
        }
    }
}
