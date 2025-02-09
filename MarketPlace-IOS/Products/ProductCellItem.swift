
import SwiftUI
import Shimmer


struct ProductCellItem: View {
    @State private var quantity = 1
    @State private var currentImageIndex = 0
    var viewModel: ProductCellItemViewModel
    @State private var productImage: UIImage? = nil
    private var discount: Int? {
        return 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Carousel
            ZStack(alignment: .bottomTrailing) {
                if let productImage = productImage {
                    Image(uiImage: productImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .shimmering(active: true)
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .padding(8)
            }.onAppear {
                print("ProductCellItem appeared for")
                viewModel.downloadProductImages { image in
                    DispatchQueue.main.async {
                        self.productImage = image ?? UIImage(named: "placeholder")
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Product Name and Rating
                HStack {
                    Text(viewModel.productTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", 3))
                        Text("/10")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                
                // Price Information
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(String(format: "%.2f", viewModel.productPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("$\(String(format: "%.2f", viewModel.productPrice))")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.gray)
                    
                    if let discount = discount {
                        Text("\(discount)% OFF")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                // Description
                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Stock Information
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(viewModel.stock) in stock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if UserDetails.isAppOwners {
                        Menu {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    viewModel.editProduct()
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(action: {
                                    viewModel.deleteProduct()
                                }) {
                                    Label("Delete", systemImage: "trash")
                                        .foregroundColor(.red) // Make delete button red
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis") // Vertical menu button (three dots)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }

                    } else {
                        CartButtonView()
                    }
                }
                
            }.padding()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
        .onTapGesture {
            viewModel.didTapOnProduct()
        }
        
    }
}





struct AddToCartView: View {
    @State var itemCount: Int = 0
    @Binding var showLoginview: Bool
    @ObservedObject var viewModel:ProductCardViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State var isLoading: Bool = false
    var body: some View {
        if itemCount == 0 {
            addButton(action: {
                updateCart(itemCount: 1)
            }).shimmering(active: isLoading)
        } else {
            // Counter view when items are added
            HStack(spacing: 12) {
                // Minus Button
                counterButton(
                    systemImage: "minus",
                    action: {
                        if itemCount > 0 {
                            updateCart(itemCount: itemCount - 1)
                        }
                    }
                )
                
                // Item Count
                Text("\(itemCount)")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // Plus Button
                counterButton(
                    systemImage: "plus",
                    action: {
                        updateCart(itemCount: itemCount + 1)
                    }
                )
            }.shimmering(active: isLoading)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    func updateCart(itemCount: Int) {
        if UserDetails.isLoggedIn {
            isLoading = true
            cartViewModel.createCart(storeID: viewModel.product.store_id, products: [.init(productID: viewModel.product._id, quantity: itemCount)]) { cartCount in
                if let cartCount {
                    self.itemCount = cartCount
                    cartViewModel.cartItemCount = itemCount
                }
                isLoading = false
            }
        } else {
            showLoginview = true
        }
    }
    
    // MARK: - Reusable Components
    
    /// Button for "+" and "-" actions in the counter
    private func counterButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white))
        }
    }
    
    /// Initial "Add to Cart" button
    private func addButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct PriceView: View {
    var price: Double = 0

    var body: some View {
        HStack(alignment: .center) {
            Text("$")
                .foregroundColor(.black)
                .offset(x: 8, y: -2)
                .font(.system(size: 12, weight: .bold, design: .default))

            Text(String(format: "%.0f", price))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .bold, design: .default))

            let cents = (price * 100).truncatingRemainder(dividingBy: 100)
            if cents > 0 {
                Text(String(format: "%02d", Int(cents)))
                    .offset(x: -8, y: -2)
                    .font(.system(size: 12, weight: .bold, design: .default))
                
            }
        }
    }
}

struct CartButtonView: View {
    @State private var quantity: Int = 0
    @State private var showControls = false
    
    var body: some View {
        Group {
            if quantity == 0 {
                // Add to Cart Button
                Button(action: {
                    withAnimation(.spring()) {
                        quantity = 1
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 40)
                    .background(Color.black)
                    .cornerRadius(10)
                }
            } else {
                // Quantity Controls
                HStack(spacing: 15) {
                    Button {
                        withAnimation(.spring()) {
                            if quantity > 0 {
                                quantity -= 1
                            }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(quantity > 1 ? .red : .red)
                    }
                    .disabled(quantity == 0)
                    
                    Text("\(quantity)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button {
                        withAnimation(.spring()) {
                            quantity += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.gray)
                .cornerRadius(10)
            }
        }.background(.white)
        .onChange(of: quantity) { newValue in
            if newValue == 0 {
                // Handle empty cart logic
            } else {
                // Update cart with new quantity
               
            }
        }
    }
}


