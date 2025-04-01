import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    @State var product: Product
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @StateObject private var bidViewModel = BidViewModel()

    @State private var isEditing = false
    @State private var selectedImageIndex = 0
    @State private var showSuccessMessage = false
    @State private var userBidInput: String = ""

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textColor = Color.black

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    TopBarView(showLogoutButton: false, showAddButton: false)

                    HStack {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(buttonColor)
                        }
                        .padding(.trailing)
                    }
                }
                .navigationBarBackButtonHidden(true)

                ScrollView {
                    VStack(spacing: 12) {
                        imageCarousel
                            .onAppear {
                                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.gray
                                UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
                            }

                        productInfoSection

                        Divider().padding(.horizontal)

                        productAttributes
                            .padding(.horizontal)

                        Divider().padding(.horizontal)

                        productDescription
                            .padding(.horizontal)

                        if product.sellerID != authViewModel.userID && !(product.isSold ?? false) {
                            biddingSection
                        }

                        Spacer()

                        actionButtons
                    }
                    .padding()
                }
            }

            if showSuccessMessage {
                VStack {
                    Spacer()
                    Text("Product updated successfully!")
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
                        .padding()
                    Spacer()
                }
                .zIndex(1)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            productViewModel.fetchProducts()
            addToRecentlyViewed(product: product)

            if categoryViewModel.categories.isEmpty {
                categoryViewModel.fetchCategories()
            }
        }
    }

    struct DetailRow: View {
        var title: String
        var value: String

        private let textColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

        var body: some View {
            HStack {
                Text("\(title):")
                    .font(.custom("ReemKufi-Bold", size: 18))
                    .foregroundColor(textColor)

                Spacer()

                Text(value)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 5)
        }
    }

    func addToRecentlyViewed(product: Product) {
        var recentlyViewed = UserDefaults.standard.array(forKey: "recentlyViewed") as? [String] ?? []

        if let productID = product.id, !recentlyViewed.contains(productID) {
            recentlyViewed.append(productID)
        }

        if recentlyViewed.count > 10 {
            recentlyViewed.removeFirst()
        }

        UserDefaults.standard.set(recentlyViewed, forKey: "recentlyViewed")
    }

    private var imageCarousel: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(Array(product.imageUrls.enumerated()), id: \.1) { index, imageUrl in
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 320)
    }

    private var productInfoSection: some View {
        VStack(spacing: 8) {
            Text(product.name)
                .font(.custom("ReemKufi-Bold", size: 26))
                .foregroundColor(.black)
            Text("QR \(product.price, specifier: "%.2f")")
                .font(.custom("ReemKufi-Bold", size: 22))
                .foregroundColor(buttonColor)
        }
    }

    private var productAttributes: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let category = categoryViewModel.categories.first(where: { $0.id == product.categoryID }) {
                DetailRow(title: "Category", value: category.name)
            }
            DetailRow(title: "Gender", value: product.gender)
            DetailRow(title: "Condition", value: product.condition)
            if let size = product.size, !size.isEmpty {
                DetailRow(title: "Size", value: size)
            }
        }
    }

    private var productDescription: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description")
                .font(.custom("ReemKufi-Bold", size: 20))
                .foregroundColor(buttonColor)

            Text(product.description.isEmpty ? "Not included" : product.description)
                .font(.system(size: 18))
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 150, alignment: .topLeading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
        }
    }

    private var biddingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Place Your Offer")
                .font(.custom("ReemKufi-Bold", size: 20))
                .foregroundColor(buttonColor)

            TextField("Enter your offer (QR)", text: $userBidInput)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))

            Button(action: {
                if let userID = authViewModel.userID {
                    bidViewModel.submitBid(for: product, amount: userBidInput, bidderID: userID) { success in
                        if success {
                            userBidInput = ""
                        }
                    }
                }
            }) {
                Text("Submit Offer")
                    .font(.custom("ReemKufi-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var actionButtons: some View {
        HStack {
            if product.sellerID != authViewModel.userID && !(product.isSold ?? false) {
                Button(action: {
                    productViewModel.toggleLike(product: product)
                }) {
                    Image(systemName: productViewModel.likedProducts.contains(where: { $0.id == product.id }) ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(productViewModel.likedProducts.contains(where: { $0.id == product.id }) ? buttonColor : .gray)
                }
                .padding()
            }

            if product.sellerID == authViewModel.userID && !(product.isSold ?? false) {
                Button(action: {
                    isEditing = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(buttonColor)
                }
                .sheet(isPresented: $isEditing, onDismiss: {
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        showSuccessMessage = false
                    }
                }) {
                    EditProductView(product: $product)
                }
                .padding()
            }

            Spacer()

            if product.sellerID == authViewModel.userID {
                VStack(spacing: 2) {
                    Text("Your Product")
                        .font(.custom("ReemKufi-Bold", size: 18))
                    if product.isSold ?? false {
                        Text("(Sold Out)")
                            .font(.system(size: 16))
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            } else if product.isSold ?? false {
                Text("Sold Out")
                    .font(.custom("ReemKufi-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            } else {
                Button(action: {
                    cartViewModel.addProduct(product)
                }) {
                    Text("Add to Cart")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding(.horizontal)
    }
}
