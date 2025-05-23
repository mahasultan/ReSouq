import SwiftUI
import FirebaseFirestore

struct AddProductView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var categoryViewModel = CategoryViewModel()
    @StateObject var productVM = ProductViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var productViewModel: ProductViewModel


    @State private var name = ""
    @State private var price = ""
    @State private var description = ""
    @State private var selectedCategoryID = ""
    @State private var selectedGender = ""
    @State private var selectedCondition = ""
    @State private var selectedImages: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var selectedSize = ""
    @State private var showSuccessMessage = false
    @State private var showSizeChartPopup = false
    

    private let genderOptions = ["Female", "Male", "Unisex"]
    private let conditionOptions = ["New", "Used - Like New", "Used - Good", "Used - Acceptable"]
    private let shoeSizes = (36...44).map { "\($0)" }
    private let clothingSizes = ["XS", "S", "M", "L", "XL"]
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textFieldBorderColor = Color.gray.opacity(0.5)

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TopBarView(showLogoutButton: false, showAddButton: false)

                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Add Product")
                                .font(.custom("ReemKufi-Bold", size: 30))
                                .foregroundColor(buttonColor)
                                .padding(.top, 10)

                            VStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(selectedImages.indices, id: \.self) { index in
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .clipped()
                                        }

                                        Button(action: {
                                            isImagePickerPresented = true
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                                                    .frame(width: 120, height: 120)
                                                    .background(Color.white)

                                                VStack {
                                                    Image(systemName: "plus.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(buttonColor)
                                                    Text("Add Image")
                                                        .font(.custom("ReemKufi-Bold", size: 16))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                        .frame(width: 120, height: 120)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .sheet(isPresented: $isImagePickerPresented) {
                                ImagePicker(selectedImages: $selectedImages)
                            }

                            VStack(spacing: 15) {
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
                                    title: "Category",
                                    selection: $selectedCategoryID,
                                    options: productViewModel.getSortedCategoryFrequencies(categories: categoryViewModel.categories)
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
                                        Text("Select Size (EU)")
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
                                        Button(action: {
                                                   showSizeChartPopup = true
                                               }) {
                                                   Text("Click for Size Chart Conversion")
                                                       .font(.custom("ReemKufi-Bold", size: 16))
                                                       .foregroundColor(buttonColor)
                                                       .underline() 
                                                       .padding(.top, 10)
                                               }
                                               .padding(.horizontal)
                                            
                                    }
                                }
                            }

                            if let errorMessage = productVM.errorMessage {
                                Text(errorMessage)
                                    .font(.custom("ReemKufi-Bold", size: 14))
                                    .foregroundColor(.red)
                                    .padding()
                            }

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
                
                if showSizeChartPopup {
                                    Color.black.opacity(0.4)
                                        .ignoresSafeArea()
                                        .onTapGesture {
                                            showSizeChartPopup = false
                                        }

                                    VStack {
                                        Image("SizeChart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 300)
                                            .cornerRadius(12)
                                            
                                        Button("Close") {
                                                    showSizeChartPopup = false
                                                }
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))  // Maroon color
                                                .cornerRadius(8)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 10)
                                    .padding(5)
                                }
                            

                if showSuccessMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Product added successfully!")
                                .font(.custom("ReemKufi-Bold", size: 16))
                                .padding()
                                .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                .foregroundColor(buttonColor)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(buttonColor, lineWidth: 2)
                                )
                                .shadow(radius: 10)
                            Spacer()
                        }
                        Spacer()
                    }
                    .zIndex(1)
                }
            }
            
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                categoryViewModel.fetchCategories()
            }
            
        }
        
    }

    private func addProduct() {
        guard let userID = authViewModel.userID,
              !name.trimmingCharacters(in: .whitespaces).isEmpty,
              let priceValue = Double(price.trimmingCharacters(in: .whitespacesAndNewlines)),
              !selectedCategoryID.isEmpty,
              !selectedGender.isEmpty,
              !selectedCondition.isEmpty,
              !selectedImages.isEmpty else {
            productVM.errorMessage = "Please fill in all fields, including at least one image."
            return
        }

        if categoryType(for: selectedCategoryID) == "Clothing" || categoryType(for: selectedCategoryID) == "Shoe" {
            guard !selectedSize.isEmpty else {
                productVM.errorMessage = "Please select a size."
                return
            }
        }

        productVM.isSubmitting = true

        productVM.saveProduct(
            userID: userID,
            name: name,
            price: priceValue,
            description: description,
            categoryID: selectedCategoryID,
            gender: selectedGender,
            condition: selectedCondition,
            size: selectedSize,
            images: selectedImages
        ) { success in
            DispatchQueue.main.async {
                productVM.isSubmitting = false
                if success {
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSuccessMessage = false
                        resetForm()
                        navigationManager.currentPage = "Home"
                    }
                }
            }
        }
    }

    private func resetForm() {
        name = ""
        price = ""
        description = ""
        selectedCategoryID = ""
        selectedGender = ""
        selectedCondition = ""
        selectedSize = ""
        selectedImages.removeAll()
        isImagePickerPresented = false
        productVM.errorMessage = nil
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
                .foregroundColor(buttonColor)
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
