//
//  AddProductView.swift
//  ReSouq
//
//  Created by Mohammed Al-Khalifa on 04/03/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct AddProductView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var categoryVM = CategoryViewModel()
    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var selectedCategoryID = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                TextField("Product Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Price (QAR)", text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding()
                
                Picker("Select Category", selection: $selectedCategoryID) {
                    Text("Select a category").tag("")
                    ForEach(categoryVM.categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: addProduct) {
                    if isSubmitting {
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
                .disabled(isSubmitting)
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
              !selectedCategoryID.isEmpty else {
            errorMessage = "Please fill in all fields and select a category."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        let newProduct = Product(
            name: name,
            price: priceValue,
            description: description,
            sellerID: userID,
            categoryID: selectedCategoryID
        )
        
        let db = Firestore.firestore()
        do {
            try db.collection("products").addDocument(from: newProduct) { error in
                DispatchQueue.main.async {
                    isSubmitting = false
                    if let error = error {
                        errorMessage = "Failed to add product: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                isSubmitting = false
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
        }
    }
}
