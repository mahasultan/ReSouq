import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedShipping = "Standard"
    @State private var selectedPaymentMethod = "Apple Pay"
    @State private var navigateToOrders = false
    
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
                    .foregroundColor(.white)
                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
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
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shipping Options")
                        .font(.headline)
                        .foregroundColor(.black)
                    Picker("Shipping", selection: $selectedShipping) {
                        ForEach(shippingOptions, id: \.self) { option in
                            Text(option).foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Payment Method")
                        .font(.headline)
                        .foregroundColor(.black)
                    Picker("Payment", selection: $selectedPaymentMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method).foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(spacing: 5) {
                        Text("Subtotal: QR \(String(format: "%.2f", cartViewModel.cart.totalPrice))")
                        Text("Shipping: \(selectedShipping.contains("Express") ? "QR 50.00" : "Free")")
                        Text(String(format: "Total: QR %.2f", totalWithShipping))
                            .bold()
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                    .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    if !cartViewModel.cart.products.isEmpty, let userID = authViewModel.userID {
                        orderViewModel.placeOrder(userID: userID, cart: cartViewModel.cart) { success in
                            if success {
                                DispatchQueue.main.async {
                                    cartViewModel.cart.products.removeAll()
                                    navigateToOrders = true
                                }
                            } else {
                                print("Order failed to save.")
                            }
                        }
                    } else {
                        print("Cannot place an order. The cart is empty.")
                    }
                }) {
                    Text("Confirm Payment")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                        .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                        .cornerRadius(10)
                }
                .padding()

                
                
                NavigationLink(
                    destination: OrderView().environmentObject(orderViewModel),
                    isActive: $navigateToOrders
                ) {
                    EmptyView()
                }
                .hidden()
                
            }
            .navigationTitle("Payment")
            .onAppear {
                cartViewModel.fetchCart() // Fetch latest cart data
            }
        }
    }}
