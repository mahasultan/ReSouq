//
//  Untitled.swift
//  ReSouq
//

import SwiftUI

struct OrderDetailView: View {
    var order: Order
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        VStack {
            Text("Order Details")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(Color.white)
                .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 10) {
                Text("Order ID: \(order.id ?? "N/A")")
                    .bold()
                Text("Date: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                Text("Total: QR \(String(format: "%.2f", order.totalPrice))")

                Divider()

                Text("Items in Order:")
                    .font(.headline)
                    .padding(.top)

                List(order.products) { item in
                    HStack {
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
                        .cornerRadius(8)

                        VStack(alignment: .leading) {
                            Text(item.product.name)
                                .bold()
                            Text("QR \(String(format: "%.2f", item.product.price))")
                                .foregroundColor(.gray)
                            Text("Quantity: \(item.quantity)")
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .navigationTitle("Order Details")
    }
}
