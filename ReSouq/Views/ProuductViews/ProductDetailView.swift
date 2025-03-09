import SwiftUI

struct ProductDetailView: View {
    var product: Product
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        VStack {
            if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .scaledToFit()
                .frame(height: 300)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .foregroundColor(.gray)
            }

            Text(product.name)
                .font(.title)
                .bold()

            Text("QR \(product.price, specifier: "%.2f")")
                .foregroundColor(.red)
                .font(.title2)

            Text(product.description)
                .padding()

            Spacer()

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
        .navigationTitle("Item Details")
    }
}
