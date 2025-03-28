import SwiftUI

struct ProductItem: View {
    var product: Product
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let beigeBackground = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        VStack {
            NavigationLink(destination: ProductDetailView(product: product)) {
                VStack {
                    AsyncImage(url: URL(string: product.imageUrls.first ?? "")) { image in
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
                        .foregroundColor(buttonColor)

                    Text("QR \(product.price, specifier: "%.2f")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .foregroundColor(.primary)
            }

            let isSold = product.isSold ?? false
            let isMine = product.sellerID == authViewModel.userID

            if isMine && isSold {
                VStack(spacing: 2) {
                    Text("Your Product")
                        .font(.system(size: 13, weight: .semibold))
                    Text("(Sold Out)")
                        .font(.system(size: 13))
                }
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 38)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(10)
                .padding(.top, 5)

            } else if isMine {
                Text("Your Product")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 120, height: 38)
                    .foregroundColor(buttonColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(buttonColor, lineWidth: 1.5)
                    )
                    .padding(.top, 5)

            } else if isSold {
                Text("Sold Out")
                    .font(.system(size: 14))
                    .frame(width: 120, height: 38)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 5)

            } else {
                Button(action: {
                    cartViewModel.addProduct(product)
                }) {
                    Text("Add to Cart")
                        .font(.system(size: 14))
                        .frame(width: 120, height: 38)
                        .background(buttonColor)
                        .foregroundColor(beigeBackground)
                        .cornerRadius(10)
                }
                .padding(.top, 5)
            }
        }
        .frame(width: 160)
        .padding()
        .background(beigeBackground)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
