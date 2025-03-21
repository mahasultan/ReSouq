import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    var product: Product
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var productViewModel: ProductViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    @State private var isEditing = false
    @State private var selectedImageIndex = 0
    
    
    private let buttonColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
    private let textColor = Color.black
    
    var body: some View {
        VStack {
            ZStack {
                TopBarView(showLogoutButton: false, showAddButton: false)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(buttonColor)
                    }
                    .padding(.trailing)
                }
            }
            .navigationBarBackButtonHidden(true)
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(product.imageUrls.enumerated()), id: \.1) { index, imageUrl in
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
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.gray
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
                    }
                    
                    Text(product.name)
                        .font(.custom("ReemKufi-Bold", size: 26))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    
                    Text("QR \(product.price, specifier: "%.2f")")
                        .font(.custom("ReemKufi-Bold", size: 22))
                        .foregroundColor(buttonColor)
                    
                    Divider().padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        let categoryName = categoryViewModel.categories.first(where: { $0.id == product.categoryID })?.name ?? "Unknown"
                        
                        DetailRow(title: "Category", value: categoryName)
                        DetailRow(title: "Gender", value: product.gender)
                        DetailRow(title: "Condition", value: product.condition)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.custom("ReemKufi-Bold", size: 20))
                            .foregroundColor(buttonColor)
                        
                        Text(product.description)
                            .font(.system(size: 18))
                            .foregroundColor(textColor)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 150, alignment: .topLeading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            productViewModel.toggleLike(product: product)
                        }) {
                            Image(systemName: productViewModel.likedProducts.contains(where: { $0.id == product.productID }) ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(productViewModel.likedProducts.contains(where: { $0.id == product.productID }) ? buttonColor : .gray)
                        }
                        .padding()
                        
                        if product.sellerID == authViewModel.userID {
                            Button(action: {
                                isEditing = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(buttonColor)
                            }
                            .sheet(isPresented: $isEditing) {
                                EditProductView(product: product)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        if product.isSold ?? false {
                            Text("Sold Out")
                                .font(.custom("ReemKufi-Bold", size: 18))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding()
                        } else {
                            Button(action: {
                                cartViewModel.addProduct(product)
                            }) {
                                Text("Add to Cart")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1)))
                                    .foregroundColor(Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1)))
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                        }}
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                productViewModel.fetchProducts()
            }
            .onAppear {
                if categoryViewModel.categories.isEmpty {
                    categoryViewModel.fetchCategories()
                }
            }
            .sheet(isPresented: $isEditing) {
                EditProductView(product: product)
            }
        }
    }
    
    // MARK: - Custom UI Components
    struct DetailRow: View {
        var title: String
        var value: String
        
        private let textColor = Color(UIColor(red: 105/255, green: 22/255, blue: 22/255, alpha: 1))
        
        var body: some View {
            HStack {
                Text("\(title):")
                    .font(.custom("ReemKufi-Bold", size: 18))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 5)
        }
        
    }

