import SwiftUI

struct ProductItem: View {
    var product: Product
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        VStack {
            NavigationLink(destination: ProductDetailView(product: product)) {
                VStack {
                    AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 120)
                    .cornerRadius(10)

                    Text(product.name)
                        .font(.system(size: 14))
                        .bold()

                    Text("QR \(product.price, specifier: "%.2f")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }

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
                .padding(.top, 5)
            }
        }
        .frame(width: 160)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
