//
//  ProductDetailSubviews.swift
//  ReSouq
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductImageCarouselView: View {
    let imageUrls: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(imageUrls.enumerated()), id: \.1) { index, imageUrl in
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 320)
    }
}

struct ProductSpecsView: View {
    let product: Product
    let categoryName: String?

    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let name = categoryName {
                DetailRow(title: "Category", value: name)
            }
            DetailRow(title: "Gender", value: product.gender)
            DetailRow(title: "Condition", value: product.condition)
            if let size = product.size, !size.isEmpty {
                DetailRow(title: "Size", value: size)
            }
        }
    }
}

struct ProductDescriptionView: View {
    let description: String
    let buttonColor: Color
    let textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DetailRow(title: "Description", value: "Not included")
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.custom("ReemKufi-Bold", size: 20))
                        .foregroundColor(buttonColor)

                    Text(description)
                        .font(.system(size: 18))
                        .foregroundColor(textColor)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 150, alignment: .topLeading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                }
            }
        }
    }
}

struct BidInputView: View {
    let product: Product
    @Binding var userBidInput: String
    let buttonColor: Color
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Place Your Offer")
                .font(.custom("ReemKufi-Bold", size: 20))
                .foregroundColor(buttonColor)

            TextField("Enter your offer (QR)", text: $userBidInput)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))

            Button(action: {
                onSubmit()
            }) {
                Text("Submit Offer")
                    .font(.custom("ReemKufi-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
