import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct BidOffersView: View {
    var product: Product
    @StateObject private var bidViewModel = BidViewModel()
    @State private var showSuccess = false
    @EnvironmentObject var cartViewModel: CartViewModel


    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let backgroundColor = Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
    private let textColor = Color.black

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Product Image & Info
                if let imageUrl = product.imageUrls.first, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                        .padding(.bottom)
                }

                Text(product.name)
                    .font(.custom("ReemKufi-Bold", size: 24))
                    .foregroundColor(textColor)

                Text("QR \(String(format: "%.2f", product.price))")
                    .font(.custom("ReemKufi-Bold", size: 20))
                    .foregroundColor(buttonColor)

                Divider()

                //  Active Offers
                Text("Offers")
                    .font(.custom("ReemKufi-Bold", size: 22))

                if bidViewModel.bids.isEmpty {
                    Text("No current offers.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(bidViewModel.bids, id: \.id) { bid in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Bidder: \(bid.id.prefix(6))...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)

                                Text("QR \(bid.amount, specifier: "%.2f")")
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                            }

                            Spacer()

                            Button(action: {
                                bidViewModel.acceptBid(for: product, bidderID: bid.id, bidAmount: bid.amount) { success in
                                    if success {
                                        showSuccess = true
                                    }
                                }


                            }) {
                                Text("Accept")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(bidViewModel.pastBids.isEmpty ? buttonColor : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(!bidViewModel.pastBids.isEmpty)

                            
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }

                // Confirmation
                if showSuccess {
                    Text("Offer accepted!!")
                        .foregroundColor(buttonColor)
                        .font(.system(size: 16, weight: .medium))
                }

                // Past Offers
                if !bidViewModel.pastBids.isEmpty {
                    Divider().padding(.vertical)

                    Text("accepted Offer")
                        .font(.custom("ReemKufi-Bold", size: 20))

                    ForEach(bidViewModel.pastBids, id: \.id) { bid in
                        HStack {
                            Text("Bidder ID: \(bid.id.prefix(6))...")
                            Spacer()
                            Text("QR \(bid.amount, specifier: "%.2f")")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
        }
        .onAppear {
            bidViewModel.fetchBids(for: product.productID ?? "")
        }
    }
}
