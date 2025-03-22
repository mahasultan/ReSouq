import SwiftUI
import SDWebImageSwiftUI

struct EditProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var productVM = ProductViewModel()
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    @Binding var product: Product

    @State private var name: String
    @State private var price: String
    @State private var description: String
    @State private var selectedCategoryID: String
    @State private var selectedGender: String
    @State private var selectedCondition: String
    @State private var selectedSize: String
    @State private var selectedImages: [UIImage] = []
    @State private var existingImageUrls: [String]
    @State private var isImagePickerPresented = false

    private let genderOptions = ["Female", "Male", "Unisex"]
    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let clothingSizes = ["XS", "S", "M", "L", "XL"]
    private let shoeSizes = (36...44).map { "\($0)" }
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textFieldBorderColor = Color.gray.opacity(0.5)

    init(product: Binding<Product>) {
        self._product = product
        _name = State(initialValue: product.wrappedValue.name)
        _price = State(initialValue: String(product.wrappedValue.price))
        _description = State(initialValue: product.wrappedValue.description)
        _selectedCategoryID = State(initialValue: product.wrappedValue.categoryID)
        _selectedGender = State(initialValue: product.wrappedValue.gender)
        _selectedCondition = State(initialValue: product.wrappedValue.condition)
        _selectedSize = State(initialValue: product.wrappedValue.size ?? "")
        _existingImageUrls = State(initialValue: product.wrappedValue.imageUrls)
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
                                .stroke(textFieldBorderColor, lineWidth: 1)
                                .frame(height: 100)
                                .zIndex(2)
                        }
                        .padding(.horizontal)

                        SearchableDropdownPicker(
                            title: "Select Category",
                            selection: $selectedCategoryID,
                            options: categoryViewModel.categories.map { ($0.name, $0.id) }
                        )

                        CustomDropdownPicker(title: "Select Gender", selection: $selectedGender, options: genderOptions.map { ($0, $0) })
                        CustomDropdownPicker(title: "Select Condition", selection: $selectedCondition, options: conditionOptions.map { ($0, $0) })

                        if categoryType(for: selectedCategoryID) == "Clothing" {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Size")
                                    .font(.custom("ReemKufi-Bold", size: 18))
                                    .foregroundColor(buttonColor)
                                    .padding(.leading)

                                Picker("Size", selection: $selectedSize) {
                                    ForEach(clothingSizes, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal)
                            }
                        } else if categoryType(for: selectedCategoryID) == "Shoe" {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Size")
                                    .font(.custom("ReemKufi-Bold", size: 18))
                                    .foregroundColor(buttonColor)
                                    .padding(.leading)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                                    ForEach(shoeSizes, id: \.self) { size in
                                        Button(action: {
                                            selectedSize = size
                                        }) {
                                            Text(size)
                                                .frame(minWidth: 44)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(selectedSize == size ? buttonColor : Color.gray.opacity(0.2))
                                                .foregroundColor(selectedSize == size ? .white : .black)
                                                .cornerRadius(10)
                                                .font(.custom("ReemKufi-Bold", size: 16))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

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
                                    .foregroundColor(.white)
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
                categoryViewModel.fetchCategories()
            }
        }
    }

    private func updateProduct() {
        guard let priceValue = Double(price.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            productVM.errorMessage = "Invalid price format."
            return
        }

        productVM.isSubmitting = true

        productVM.updateProduct(
            productID: product.id!,
            name: name,
            price: priceValue,
            description: description,
            categoryID: selectedCategoryID,
            gender: selectedGender,
            condition: selectedCondition,
            size: selectedSize,
            images: selectedImages,
            existingImageUrls: existingImageUrls
        ) { success in
            DispatchQueue.main.async {
                productVM.isSubmitting = false
                if success {
                    productVM.fetchProducts()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let updated = productVM.products.first(where: { $0.id == product.id }) {
                            self.product = updated
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func categoryType(for id: String) -> String? {
        if let category = categoryViewModel.categories.first(where: { $0.id == id }),
           let parentID = category.parentCategoryID {
            if parentID == "1" {
                return "Clothing"
            } else if parentID == "14" {
                return "Shoe"
            }
        }
        return nil
    }
}
