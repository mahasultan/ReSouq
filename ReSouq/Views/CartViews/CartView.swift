//
//  CartView.swift
//  ReSouq
//

import SwiftUI
import SDWebImageSwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedShipping = "Standard"
    @State private var selectedPaymentMethod = "Apple Pay"
    
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
                TopBarView(showLogoutButton: false, showAddButton: false)

                HStack {
                    Text("My Cart")
                        .font(.custom("ReemKufi-Bold", size: 25))
                        .foregroundColor(.black)

                    Text("(\(cartViewModel.cart.products.count) items)")
                        .font(.custom("ReemKufi-Bold", size: 25))
                        .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))

                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                if cartViewModel.cart.products.isEmpty {
                    Text("Your cart is empty")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        VStack {
                            ForEach(cartViewModel.cart.products) { cartItem in
                                VStack {
                                    HStack {
                                        if let imageURL = cartItem.product.imageURL, let url = URL(string: imageURL) {
                                            WebImage(url: url)
                                                .resizable()
                                                .indicator(.activity)
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .clipped()
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                                .foregroundColor(.gray)
                                        }

                                        NavigationLink(destination: ProductDetailView(product: cartItem.product)) {
                                            VStack(alignment: .leading) {
                                                Text(cartItem.product.name)
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))

                                                Text("QR \(String(format: "%.2f", cartItem.product.price))")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 16))
                                            }
                                        }

                                        Spacer()

                                        Button(action: {
                                            cartViewModel.removeProduct(cartItem.product)
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                        }
                                    }
                                    .padding(.horizontal)

                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }

                if !cartViewModel.cart.products.isEmpty {
                    VStack(spacing: 10) {
                        Text("Total: QR \(String(format: "%.2f", cartViewModel.cart.totalPrice))")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

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

                Spacer()
            }
            .onAppear {
                cartViewModel.fetchCart()
            }
            .navigationBarBackButtonHidden(true)
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

