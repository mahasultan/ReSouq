import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    var product: Product
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    // App Colors
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Dark Red
    private let textColor = Color.black

    var body: some View {
        VStack {
            // Top Bar with Back Button on the Right
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
                VStack(spacing: 12) { // Reduced spacing
                    // Product Image
                    if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.top, 10)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .foregroundColor(.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    // Product Name (Black & Less Spacing)
                    Text(product.name)
                        .font(.custom("ReemKufi-Bold", size: 26))
                        .foregroundColor(.black)
                        .padding(.top, 5) // Reduced spacing

                    // Price (Less Spacing)
                    Text("QR \(product.price, specifier: "%.2f")")
                        .font(.custom("ReemKufi-Bold", size: 22))
                        .foregroundColor(buttonColor)

                    Divider()
                        .padding(.horizontal)

                    // Category, Gender, and Condition
                    VStack(alignment: .leading, spacing: 10) {
                        let categoryName = categoryViewModel.categories.first(where: { $0.id == product.categoryID })?.name ?? "Unknown"

                        DetailRow(title: "Category", value: categoryName)
                        DetailRow(title: "Gender", value: product.gender)
                        DetailRow(title: "Condition", value: product.condition)
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.custom("ReemKufi-Bold", size: 20))
                            .foregroundColor(buttonColor)

                        Text(product.description)
                            .font(.system(size: 18))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 150, alignment: .topLeading) // Fixed size
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Like and Add to Cart Buttons
                    HStack {
                        // Like Button
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

                        Spacer()

                        // Add to Cart Button or Sold Out Label
                        if let productID = product.id, cartViewModel.soldOutProducts.contains(productID) {
                            Text("Sold Out")
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        } else {
                            Button(action: {
                                cartViewModel.addProduct(product)
                            }) {
                                Text("Add to Cart")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                    .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            if categoryViewModel.categories.isEmpty {
                categoryViewModel.fetchCategories()
            }
        }
    }
}

// MARK: - Custom UI Components

// Detail Row for Category, Gender, and Condition
struct DetailRow: View {
    var title: String
    var value: String

    private let textColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Dark Red

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
