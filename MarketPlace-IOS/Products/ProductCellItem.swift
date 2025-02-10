
import SwiftUI
import Shimmer


struct ProductCellItem: View {
    @State private var quantity = 1
    @State private var currentImageIndex = 0
    var viewModel: ProductCellItemViewModel
    @State private var productImage: UIImage? = nil
    @Binding var showLoginview: Bool
    @EnvironmentObject var cartViewModel: CartViewModel

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
                        .font(.system(size: 15))
                        .fontWeight(.semibold).lineLimit(2)
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
                    .font(.system(size: 13))
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
                        CartButtonView(showLoginview: $showLoginview, viewModel: viewModel)
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
    @State private var showControls = false
    @Binding var showLoginview: Bool
    @State var isLoading: Bool = false
    @EnvironmentObject var cartViewModel: CartViewModel
    var viewModel: ProductCellItemViewModel
    var body: some View {
        Group {
            if viewModel.itemCount  == 0 {
                // Add to Cart Button
                Button(action: {
                    withAnimation(.spring()) {
                        if UserDetails.isLoggedIn {
                            updateCart(itemCount: 1)
                        } else {
                            showLoginview = true
                        }
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
                            if UserDetails.isLoggedIn {
                                if viewModel.itemCount  > 0 {
                                    let newValue = viewModel.itemCount - 1
                                    updateCart(itemCount: newValue)
                                }
                            } else {
                                showLoginview = true
                            }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.itemCount  > 1 ? .red : .red)
                    }
                    .disabled(viewModel.itemCount  == 0)
                    
                    Text("\(viewModel.itemCount)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    Button {
                        withAnimation(.spring()) {
                            let newValue = viewModel.itemCount + 1
                            updateCart(itemCount: newValue)
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
        .shimmering(active: isLoading)
        .onChange(of: viewModel.itemCount) { newValue in
            updateCart(itemCount: newValue)
        }
    }
    
    func updateCart(itemCount: Int) {
        if UserDetails.isLoggedIn {
            isLoading = true
            cartViewModel.createCart(storeID: viewModel.product.store_id, products: [.init(productID: viewModel.product.product_id, quantity: itemCount)]) { cartCount,quantity  in
                if let cartCount {
                    viewModel.itemCount = quantity ?? 0
                    cartViewModel.cartItemCount = cartCount
                }
                isLoading = false
            }
        } else {
            showLoginview = true
        }
    }
}


