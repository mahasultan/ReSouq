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

    @State private var selectedSavedAddress: String? = nil
    @State private var shippingAddress: String = ""
    @State private var showAlert = false

    let shippingOptions = [
        "Standard (7-10 days) - Free",
        "Express (1-2 days) - 50 QR"
    ]

    let paymentMethods = ["Apple Pay", "Card"]

    var savedAddresses: [String] { authViewModel.user?.savedAddresses ?? [] }

    var shippingCost: Double {
        return selectedShipping.contains("Express") ? 50.0 : 0.0
    }

    var totalWithShipping: Double {
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
                            ForEach(cartViewModel.cart.products) { cartItem in
                                VStack {
                                    HStack {
                                        if let imageURL = cartItem.product.imageUrls.first, let url = URL(string: imageURL) {
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

                            Divider()
                                .padding(.vertical, 10)

                            // Shipping Address Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Shipping Address")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                if let savedAddresses = authViewModel.user?.savedAddresses, !savedAddresses.isEmpty {
                                    Picker("Select an address", selection: $selectedSavedAddress) {
                                        Text("Enter a new address").tag(nil as String?)
                                        ForEach(savedAddresses, id: \.self) { address in
                                            Text(address).tag(address as String?)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }

                                if selectedSavedAddress == nil {
                                    TextField("Enter your shipping address", text: $shippingAddress)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.top, 10)


                            // Order Summary
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
                                        Text(shippingCost > 0 ? "QR \(String(format: "%.2f", shippingCost))" : "Free")
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

                            Button(action: {
                                if !cartViewModel.cart.products.isEmpty, let userID = authViewModel.userID {
                                    let finalShippingAddress = selectedSavedAddress ?? shippingAddress.trimmingCharacters(in: .whitespaces)

                                    if finalShippingAddress.isEmpty {
                                        print("ERROR: No shipping address provided")
                                        return
                                    }

                                    orderViewModel.placeOrder(userID: userID, cart: cartViewModel.cart, shippingAddress: finalShippingAddress) { savedOrder in
                                        DispatchQueue.main.async {
                                            if let savedOrder = savedOrder {
                                                authViewModel.saveShippingAddress(finalShippingAddress)
                                                self.placedOrder = savedOrder
                                                print("Stored Order ID: \(self.placedOrder?.id ?? "nil")")
                                                print("Stored Products Count: \(self.placedOrder?.products.count ?? 0)")
                                                print("Stored Shipping Address: \(self.placedOrder?.shippingAddress ?? "None")")

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    cartViewModel.clearCart()
                                                    cartViewModel.markProductsAsSoldOut()
                                                }

                                                self.navigateToOrders = true
                                            } else {
                                                print("Order failed to save.")
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

                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Shipping Address Required"), message: Text("Please enter or select a shipping address."), dismissButton: .default(Text("OK")))
                            }

                            NavigationLink(
                                destination: placedOrder != nil ? AnyView(OrderDetailView(order: placedOrder!)) : AnyView(EmptyView()),
                                isActive: $navigateToOrders
                            ) {
                                EmptyView()
                            }
                            .hidden()

                        }
                    }
                }
            }
            .onAppear {
                cartViewModel.fetchCart()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
