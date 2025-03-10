//
//  CartView.swift
//  ReSouq

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedShipping = "Standard"
    @State private var selectedPaymentMethod = "Apple Pay"
    @State private var navigateToPayment = false
    
    let shippingOptions = [
        "Standard (7-10 days) - Free",
        "Express (1-2 days) - 50 QR"
    ]
    
    let paymentMethods = ["Apple Pay", "Card"]
    
    var totalWithShipping: Double {
        let shippingCost = selectedShipping.contains("Express") ? 50.0 : 0.0
        return cartViewModel.cart.totalPrice + shippingCost
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("My Cart (\(cartViewModel.cart.products.count) items)")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                    .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                    .cornerRadius(10)
                
                if cartViewModel.cart.products.isEmpty {
                    Text("Your cart is empty")
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
                                    Text(String(format: "QR %.2f", cartItem.product.price))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Remove from cart button
                                Button(action: {
                                    cartViewModel.removeProduct(cartItem.product)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                }
                            }
                            .padding()
                            .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                            .cornerRadius(10)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                if !cartViewModel.cart.products.isEmpty {
                    VStack(spacing: 10) {
                        Text("Total: QR \(String(format: "%.2f", cartViewModel.cart.totalPrice))")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        // Navigation to PaymentView
                        NavigationLink(destination: PaymentView()) {
                            Text("Checkout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cart")
            .onAppear {
                cartViewModel.fetchCart()
            }
        }
    }
}

// Preview
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel())
    }
}


