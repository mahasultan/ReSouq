import SwiftUI

struct OrderDetailView: View {
    var order: Order
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        HStack {
            TopBarView(showLogoutButton: false, showAddButton: false)
        }

        VStack {
            Text("Order Details")
                .font(.custom("ReemKufi-Bold", size: 30))
                .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                .padding(.leading, 15)

            VStack(alignment: .leading, spacing: 8) {
                Text("Order ID: \(order.id ?? "N/A")")
                    .bold()
                    .font(.headline)
                Text("Date: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Total: QR \(String(format: "%.2f", order.totalPrice))")
                    .bold()
                    .font(.headline)
                    .foregroundColor(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))

                Divider().background(Color.gray.opacity(0.5))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping Address")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(order.shippingAddress ?? "No shipping address provided")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))

                Divider().background(Color.gray.opacity(0.5))

                Text("Items in Order")
                    .font(.headline)
                    .padding(.top, 5)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(order.products) { item in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: item.product.imageURL ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                    .font(.headline)
                                Text("QR \(String(format: "%.2f", item.product.price))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))))
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
