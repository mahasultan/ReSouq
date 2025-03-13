import SwiftUI
import SDWebImageSwiftUI

struct PaymentView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedShipping = "Standard"
    @State private var selectedPaymentMethod = "Apple Pay"
    @State private var navigateToOrders = false
    @State private var placedOrder: Order?



    
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
                // Top navigation bar
                TopBarView(showLogoutButton: false, showAddButton: false)

                // Page title
                HStack {
                    Text("Payment")
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
                            // List of cart items
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

                                        VStack(alignment: .leading) {
                                            Text(cartItem.product.name)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))

                                            Text("QR \(String(format: "%.2f", cartItem.product.price))")
                                                .foregroundColor(.black)
                                                .font(.system(size: 16))
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

                            // Divider between items and shipping section
                            Divider()
                                .padding(.vertical, 10)

                            // Shipping selection with vertical buttons
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Choose Shipping")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                VStack(spacing: 5) {
                                    ForEach(shippingOptions, id: \.self) { option in
                                        Button(action: {
                                            selectedShipping = option.contains("Express") ? "Express" : "Standard"
                                        }) {
                                            HStack {
                                                Text(option)
                                                    .padding(.vertical, 12)                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(selectedShipping == (option.contains("Express") ? "Express" : "Standard") ? .white : .black)

                                                if selectedShipping == (option.contains("Express") ? "Express" : "Standard") {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding()
                                            .background(selectedShipping == (option.contains("Express") ? "Express" : "Standard") ? Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)) : Color.gray.opacity(0.3))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 10)

                            // Payment method selection
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Choose Payment Method")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                Picker("Payment", selection: $selectedPaymentMethod) {
                                    ForEach(paymentMethods, id: \.self) { method in
                                        Text(method).foregroundColor(.black)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                            }

                            // Payment summary at the bottom
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Order Summary")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                VStack(spacing: 3) {
                                    HStack {
                                        Text("Subtotal")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("QR \(String(format: "%.2f", cartViewModel.cart.totalPrice))")
                                    }
                                    HStack {
                                        Text("Shipping")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text(selectedShipping == "Express" ? "QR 50.00" : "Free")
                                    }
                                    Divider()
                                    HStack {
                                        Text("Total")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text("QR \(String(format: "%.2f", totalWithShipping))")
                                            .font(.headline)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .padding(.top, 10)
                        }
                    }
                }

                
                Button(action: {
                    if !cartViewModel.cart.products.isEmpty, let userID = authViewModel.userID {
                        orderViewModel.placeOrder(userID: userID, cart: cartViewModel.cart) { savedOrder in
                            DispatchQueue.main.async {
                                if let savedOrder = savedOrder {
                                    self.placedOrder = savedOrder
                                    print(" Stored Order ID: \(self.placedOrder?.id ?? "nil")")
                                    print(" Stored Products Count: \(self.placedOrder?.products.count ?? 0)")
                                    cartViewModel.markProductsAsSoldOut()
                                    cartViewModel.clearCart()
                                    self.navigateToOrders = true
                                } else {
                                    print(" Order failed to save.")
                                }
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
                    destination: OrderDetailView(order: placedOrder ?? Order(userID: "default", products: [], totalPrice: 0.0))
                        .environmentObject(orderViewModel),
                    isActive: $navigateToOrders
                ) {
                    EmptyView()
                }
                .hidden()
                .onAppear {
                    print("DEBUG: Navigating with Order ID: \(placedOrder?.id ?? "nil")")
                    print("DEBUG: Products Count: \(placedOrder?.products.count ?? 0)")
                }

            }
            .navigationTitle("Payment")
            .onAppear {
                cartViewModel.fetchCart() // Fetch latest cart data
            }
            
        }
    }}
