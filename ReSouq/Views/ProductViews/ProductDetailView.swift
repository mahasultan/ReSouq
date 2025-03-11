import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    var product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    var body: some View {
        VStack {
            // Product Image
            if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
            }
            
            // Product Name
            Text(product.name)
                .font(.title)
                .bold()
            
            // Price
            Text("QR \(product.price, specifier: "%.2f")")
                .foregroundColor(.red)
                .font(.title2)

            Divider()
                .padding(.horizontal)

            // Category, Gender, and Condition
            VStack(alignment: .leading, spacing: 8) {
                // Find the category name based on `product.categoryID`
                let categoryName = categoryViewModel.categories.first(where: { $0.id == product.categoryID })?.name ?? "Unknown"
                
                Text("Category: \(categoryName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Gender: \(product.gender)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Condition: \(product.condition)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Divider()
                .padding(.horizontal)

            // Description
            Text(product.description)
                .padding()
            
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
                        .foregroundColor(productViewModel.likedProducts.contains(where: { $0.id == product.id }) ? Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) : .gray)
                }
                .padding()

                // Add to Cart Button or Sold Out Label
                if cartViewModel.cart.products.contains(where: { $0.product.id == product.id }) {
                    Text("Sold Out")
                        .font(.system(size: 14))
                        .frame(width: 120, height: 30)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } else {
                    Button(action: {
                        cartViewModel.addProduct(product)
                    }) {
                        Text("Add to Cart")
                            .font(.system(size: 14))
                            .frame(width: 120, height: 30)
                            .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                            .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Item Details")
        .onAppear {
            if categoryViewModel.categories.isEmpty {
                categoryViewModel.fetchCategories()
            }
        }
    }
}
