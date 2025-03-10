//
//  CartView.swift
//  ReSouq


import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("My Cart")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                if cartViewModel.cart.products.isEmpty {
                    Text("Your cart is empty ")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(cartViewModel.cart.products) { cartItem in
                            HStack {
                                AsyncImage(url: URL(string: cartItem.product.imageURL ?? "")) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading) {
                                    Text(cartItem.product.name)
                                        .bold()
                                    Text("QR \(cartItem.product.price, specifier: "%.2f")")
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // Remove from cart button
                                Button(action: {
                                    cartViewModel.removeProduct(cartItem.product)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Spacer()

                // Checkout Button
                if !cartViewModel.cart.products.isEmpty {
                    Button(action: {
                        print("Proceeding to checkout...")
                    }) {
                        Text("Checkout (QR \(cartViewModel.cart.totalPrice, specifier: "%.2f"))")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Cart")
            .onAppear {
                cartViewModel.fetchCart() // Fetch latest cart data
            }
        }
    }
}

// Preview
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel()) // Pass environment object
    }
}
