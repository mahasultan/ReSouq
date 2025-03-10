<<<<<<< HEAD:ReSouq/Views/ProductViews/ProductItem.swift
//
//  ProductItem.swift
//  ReSouq
//
//


=======
>>>>>>> main:ReSouq/Views/ProuductViews/ProductItem.swift
import SwiftUI
import SDWebImageSwiftUI

struct ProductItem: View {
    var product: Product
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        VStack {
            NavigationLink(destination: ProductDetailView(product: product)) {
                VStack {
                    if let urlString = product.imageURL, let url = URL(string: urlString) {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5)) 
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    Text(product.name)
                        .font(.system(size: 14))
                        .bold()

                    Text("QR \(product.price, specifier: "%.2f")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }

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
        .frame(width: 160)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
