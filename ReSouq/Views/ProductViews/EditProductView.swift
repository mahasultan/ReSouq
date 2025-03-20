import SwiftUI
import SDWebImageSwiftUI

struct EditProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var productVM = ProductViewModel()
    
    var product: Product

    @State private var name: String
    @State private var price: String
    @State private var description: String
    @State private var selectedCategoryID: String
    @State private var selectedGender: String
    @State private var selectedCondition: String
    @State private var selectedImages: [UIImage] = []
    @State private var existingImageUrls: [String]
    @State private var isImagePickerPresented = false
    
    private let genderOptions = ["Female", "Male", "Unisex"]
    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    
    init(product: Product) {
        self.product = product
        _name = State(initialValue: product.name)
        _price = State(initialValue: String(product.price))
        _description = State(initialValue: product.description)
        _selectedCategoryID = State(initialValue: product.categoryID)
        _selectedGender = State(initialValue: product.gender)
        _selectedCondition = State(initialValue: product.condition)
        _existingImageUrls = State(initialValue: product.imageUrls)
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

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(existingImageUrls, id: \.self) { imageUrl in
                                    WebImage(url: URL(string: imageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                Button(action: {
                                    isImagePickerPresented = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                            .frame(width: 100, height: 100)
                                            .background(Color.white)
                                        
                                        Image(systemName: "plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(selectedImages: $selectedImages)
                        }

                        CustomDropdownPicker(title: "Select Category", selection: $selectedCategoryID, options: [])
                        CustomDropdownPicker(title: "Select Gender", selection: $selectedGender, options: genderOptions.map { ($0, $0) })
                        CustomDropdownPicker(title: "Select Condition", selection: $selectedCondition, options: conditionOptions.map { ($0, $0) })

                        CustomTextField(placeholder: "Product Name", text: $name)
                        CustomTextField(placeholder: "Price (QAR)", text: $price, keyboardType: .decimalPad)
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Description (Optional)")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.leading, 18)
                                    .padding(.top, 18)
                                    .font(.custom("ReemKufi-Bold", size: 18))
                                    .zIndex(1)
                            }

                            TextEditor(text: $description)
                                .padding(.horizontal, 14)
                                .padding(.top, 8)
                                .frame(height: 100)
                                .background(Color.white)
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .foregroundColor(.black)
                                .zIndex(0)

                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .frame(height: 100)
                                .zIndex(2)
                        }
                        .padding(.horizontal)

                        if let errorMessage = productVM.errorMessage {
                            Text(errorMessage)
                                .font(.custom("ReemKufi-Bold", size: 14))
                                .foregroundColor(.red)
                                .padding()
                        }

                        Button(action: updateProduct) {
                            if productVM.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Update Product")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor)
                                    .foregroundColor(Color.white)
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
        }
    }

    private func updateProduct() {
        guard let priceValue = Double(price.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            productVM.errorMessage = "Invalid price format."
            return
        }

        productVM.isSubmitting = true

        let finalImages = selectedImages.isEmpty ? existingImageUrls : selectedImages.map { _ in "" }

        productVM.updateProduct(
            productID: product.id!,
            name: name,
            price: priceValue,
            description: description,
            categoryID: selectedCategoryID,
            gender: selectedGender,
            condition: selectedCondition,
            images: selectedImages,
            existingImageUrls: existingImageUrls 
        ) { success in
            DispatchQueue.main.async {
                productVM.isSubmitting = false
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
