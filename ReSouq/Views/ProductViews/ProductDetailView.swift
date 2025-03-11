import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    var product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    // App Colors
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)) // Beige
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) // Dark Red
    private let textColor = Color.black

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
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

                // Product Name
                Text(product.name)
                    .font(.custom("ReemKufi-Bold", size: 28))
                    .foregroundColor(buttonColor)
                    .padding(.horizontal)

                // Price
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
                        .font(.custom("ReemKufi-Bold", size: 18))
                        .foregroundColor(textColor)
                        .padding()
                        .background(Color.white.opacity(0.8))
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
                    if cartViewModel.cart.products.contains(where: { $0.product.id == product.id }) {
                        Text("Sold Out")
                            .font(.custom("ReemKufi-Bold", size: 16))
                            .frame(width: 140, height: 40)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Button(action: {
                            cartViewModel.addProduct(product)
                        }) {
                            Text("Add to Cart")
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .frame(width: 140, height: 40)
                                .background(buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationTitle("Item Details")
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
                .font(.custom("ReemKufi-Bold", size: 18))
                .foregroundColor(.black)
        }
        .padding(.vertical, 5)
    }
}
