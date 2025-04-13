import SwiftUI
import FirebaseFirestore

struct OrderDetailView: View {
    @State var order: Order
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var selectedProductToRate: Product?
    @State private var showRatingSheet = false

    private let maroon = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let beigeBackground = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(showLogoutButton: false, showAddButton: false)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Order Details")
                        .font(.custom("ReemKufi-Bold", size: 30))
                        .foregroundColor(maroon)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order ID: \(order.id ?? "N/A")").bold()
                        Text("Date: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundColor(.secondary)
                        Text("Total: QR \(String(format: "%.2f", order.totalPrice))")
                            .bold()
                            .foregroundColor(maroon)

                        Divider()

                        Text("Shipping Address").font(.headline)
                        Text(order.shippingAddress ?? "No shipping address provided")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    .padding(.horizontal)

                    Text("Items in Order")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(order.products, id: \.id) { item in
                            OrderItemCard(item: item, onRateTapped: {
                                selectedProductToRate = item.product
                                showRatingSheet = true
                            })
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
        .sheet(item: $selectedProductToRate, onDismiss: {
            updateRatedProducts()
        }) { product in
            RateProductView(
                product: product,
                orderID: order.id ?? "",
                sellerID: product.sellerID,
                buyerID: order.userID
            )
        }
        .onAppear {
            updateRatedProducts()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func updateRatedProducts() {
        guard let orderID = order.id else { return }

        orderViewModel.fetchRatedProductIDs(for: orderID) { ratedProductIDs in
            for index in order.products.indices {
                if let productID = order.products[index].product.productID,
                   ratedProductIDs.contains(productID) {
                    order.products[index].product.isRated = true
                }
            }
            print("Order products updated with isRated true")
        }
    }
}

struct OrderItemCard: View {
    var item: CartItem
    var onRateTapped: () -> Void

    private let maroon = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let beige = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .shadow(radius: 1)

                if let url = URL(string: item.product.imageUrls.first ?? "") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                    .foregroundColor(.black)

                Text("QR \(String(format: "%.2f", item.product.price))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            if item.product.isRated == true {
                Text("Rated")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(maroon)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(maroon, lineWidth: 1)
                    )
            } else {
                Button(action: onRateTapped) {
                    Text("Rate")
                        .font(.system(size: 14))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(maroon)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(beige))
    }
}
