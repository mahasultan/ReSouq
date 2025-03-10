//
//  Order.swift
//  ReSouq
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("My Orders")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                    .cornerRadius(10)

                if orderViewModel.orders.isEmpty {
                    Text("No previous orders found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(orderViewModel.orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            VStack(alignment: .leading) {
                                Text("Order #\(order.id ?? "N/A")")
                                    .bold()
                                    .foregroundColor(.black)

                                Text("Date: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("Total: QR \(String(format: "%.2f", order.totalPrice))")
                                    .font(.subheadline)
                                    .foregroundColor(.black)

                                Text("\(order.products.count) items")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                            .cornerRadius(10)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Orders")
            .onAppear {
                if let userID = authViewModel.userID {
                    orderViewModel.fetchOrders(for: userID)
                }
            }
        }
    }
}
