


import SwiftUI
import Shimmer
import Combine

struct DashboardView: View {
    @State private var stores: [Store] = []
    @StateObject var viewModel: DashBoardViewViewModel
    @State private var showLoginview: Bool = false
    init(viewModel: DashBoardViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)

    }

    var body: some View {
        CartNavigationView(title: "Stores",
                           presentLocatonSelector: $viewModel.movetoSelectLocation
                           , selectedPincode: $viewModel.pincode,
                           showlocationSelector: $viewModel.showLocationSelectionView) {
              ScrollView {
                  if $viewModel.isLoading.wrappedValue {
                      // Show shimmer effect while loading
                      LazyVStack(spacing: 16) {
                          ForEach(0..<3, id: \.self) { _ in
                              ShimmeringStoreCardPlaceholder()
                          }
                      }
                      .padding()
                  } else {
                      // Show actual content when data is loaded
                      LazyVStack(spacing: 16) {
                          ForEach(viewModel.storesResponce?.stores ?? []) { store in
                              StoreCard(viewModel: .init(store: store), showLoginview: $showLoginview)
                          }
                      }
                  }
              }
          }.sheet(isPresented: $viewModel.movetoSelectLocation) {
              if !viewModel.state.isEmpty && !viewModel.pincode.isEmpty {
                  LocationSearchView(onAddressSelected: { address in
                      viewModel.address = address
                      viewModel.pincode = address.postalCode
                      viewModel.getDashboardData(pincode: address.postalCode, state: address.state)
                  })
              }
             
          }.sheet(isPresented: $showLoginview, content: {
              LoginView()
          })
      }
}
struct StoreCard: View {
    @ObservedObject var viewModel: StoreCardViewModel
    @State private var showAllProducts = false
    @Binding var showLoginview: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Store Image
            VStack {
                AsyncImageView(imageId: viewModel.store.imageId ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .cornerRadius(10)

            
            // Store Details
            VStack(alignment: .leading, spacing: 8) {
                Text((viewModel.store.storeName?.prefix(1).uppercased() ?? "") +
                     (viewModel.store.storeName?.dropFirst() ?? ""))
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)

                
                HStack {
                    if let city = viewModel.store.city, let state = viewModel.store.state {
                        Text("City: \(city)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("State: \(state)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {

                    if !viewModel.store.products.isEmpty {
                        VStack(spacing: 8) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.store.products) { product in
                                        ProductCard(viewModel: .init(product: product), showLoginview: $showLoginview).padding([.top, .bottom],5)
                                    }
                                }
                            }
                     
                            HStack {
                                Spacer()
                                Button("View All") {
                                    UserDetails.storeId = viewModel.store.storeId
                                    showAllProducts = true
                                }
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(.top, 8)
                            }
                        }
                    }
                }
            }
            NavigationLink(
                destination: ProductListView(isCustomer: true),
                isActive: $showAllProducts
            ) {
                EmptyView()
            }
            .hidden()

        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}




struct ProductCard: View {
    @ObservedObject var viewModel:ProductCardViewModel
    @Binding var showLoginview: Bool
    @State var moveToProductDetails = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content (image and details)
            VStack(alignment: .leading, spacing: 4) {
                // Product Image
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                        .shimmering() // Add shimmer effect here
                }
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.product.product_name.prefix(1).uppercased() + viewModel.product.product_name.dropFirst().lowercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    
                    Text("$\(viewModel.product.price ?? 0.0, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Stock: \(viewModel.product.stock ?? 0)")
                        .font(.caption2)
                        .foregroundColor((viewModel.product.stock ?? 0) > 0 ? Color.gray : Color.red.opacity(0.8))
                }.padding(4)
            }
            
            AddToCartView(showLoginview: $showLoginview,
                          viewModel: viewModel)
                .offset(x: 0, y: -50)
        }
        .frame(width: 140) // Ensure consistent card size
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .onAppear {
            if let imageId = viewModel.product.imageids.first {
                viewModel.downloadImage(imageId: imageId)
            }
        }.onTapGesture {
            moveToProductDetails = true
        }
        NavigationLink(
            destination: ProductDetails(viewModel: .init(product_id: viewModel.product.id)),
            isActive: $moveToProductDetails
        ) {
            EmptyView()
        }
        .hidden()
    }
}

struct AddToCartView: View {
    @Binding var showLoginview: Bool
    @ObservedObject var viewModel:ProductCardViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State var isLoading: Bool = false
    @State private var showBottomSheet = false
    @State private var selectedVariant: ProductVariant?
   
    var body: some View {
        VStack {
            if viewModel.itemCount == 0 {
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
                            if viewModel.itemCount > 0 {
                                updateCart(itemCount: viewModel.itemCount - 1)
                            }
                        }
                    )
                    
                    // Item Count
                    Text("\(viewModel.itemCount)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // Plus Button
                    counterButton(
                        systemImage: "plus",
                        action: {
                            updateCart(itemCount: viewModel.itemCount + 1)
                        }
                    )
                }.shimmering(active: isLoading)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
        }.onViewWillAppear {
            if let index = cartViewModel.updatedCartdata.firstIndex(where: { $0.productID == viewModel.product._id }) {
                viewModel.itemCount = cartViewModel.updatedCartdata[index].quantity
            }
        }.sheet(isPresented: $showBottomSheet) {
            VariantBottomSheet(variants: viewModel.product.variants ?? [], itemCount: viewModel.requestCount) { selected, itemCount in
                self.selectedVariant = selected
                self.updateCart(itemCount: itemCount, selectedVariant: selected)
            }
        }
        
    }
    
    func updateCart(itemCount: Int, selectedVariant: ProductVariant? = nil) {
        if UserDetails.isLoggedIn {
            viewModel.requestCount = itemCount
            if selectedVariant != nil {
                isLoading = true
                cartViewModel.createCart(storeID: viewModel.product.store_id, products: [.init(productID: viewModel.product._id, quantity: itemCount, variant_type: selectedVariant?.variant_type)]) { cartCount,quantity, response in
                    if let cartCount {
                        viewModel.itemCount = quantity ?? 0
                        cartViewModel.cartItemCount = cartCount
                    }
                    isLoading = false
                }
                return
            }
            if let variants = viewModel.product.variants, variants.isEmpty {
                isLoading = true
                cartViewModel.createCart(storeID: viewModel.product.store_id, products: [.init(productID: viewModel.product._id, quantity: itemCount, variant_type: nil)]) { cartCount,quantity, response in
                    if let cartCount {
                        viewModel.itemCount = quantity ?? 0
                        cartViewModel.cartItemCount = cartCount
                    }
                    isLoading = false
                }
            } else {
                self.showBottomSheet = true
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


struct VariantBottomSheet: View {
    let variants: [ProductVariant]
    let itemCount: Int
    let onSelect: (ProductVariant, Int) -> Void
    @Environment(\.dismiss) private var dismiss
  
    var body: some View {
        VStack {
            Text("Select a Variant")
                .font(.headline)
                .padding()

            List(variants.indices, id: \.self) { index in
                let variant = variants[index]
                Button(action: {
                    onSelect(variant, itemCount)
                    dismiss()
                }) {
                    HStack {
                        Text("\(variant.variant_type ?? "Unknown")").foregroundColor(.black)
                        Spacer()
                        Text("$\(String(format: "%.2f", variant.price ?? 0.0))")
                            .foregroundColor(.black)

                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

//struct DashboardView_Previews: PreviewProvider {
//    static var previews: some View {
////        DashboardView()
//    }
//}

// MARK: - Mock Data

struct Store: Identifiable, Codable {
    let id = UUID()
    let storeId, storeName, storeType, state: String
    let pincode: Int
    let imageId: String?
    let products: [ProductMock]
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case storeName = "store_name"
        case storeType = "store_type"
        case state
        case pincode
        case imageId = "image_id"
        case products
    }
}

struct ProductMock: Identifiable, Codable {
    let id = UUID()
    let productName, description, storeId, categoryId: String
    let price: Double
    let stock: Int
    let createdAt: String?
    let isPublish: Bool
    let imageIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case description
        case price
        case stock
        case storeId = "store_id"
        case categoryId = "category_id"
        case createdAt = "created_at"
        case isPublish
        case imageIds = "imageIds"
    }
}

func mockStores() -> [Store] {
    return [
        Store(
            storeId: "678bd0b3da70427c2fe18f83",
            storeName: "Karthik",
            storeType: "Fashion",
            state: "NC",
            pincode: 28078,
            imageId: "Lenel@123",
            products: [
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: []),
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: []),
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: []),
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: []),
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: [])
                
            ]
        ),
        Store(
            storeId: "67940eb1e6556665f861cdb4",
            storeName: "SmokeFlowers",
            storeType: "Grocery",
            state: "NC",
            pincode: 28078,
            imageId: "31752c87-9102-43cb-85c9-5b11ef15d2c4_B27E25A8516840CD8B2C4DD2363C4A50.png.jpg",
            products: [
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: [])
                ,
                ProductMock(productName: "eref", description: "ewd", storeId: "ewd", categoryId: "ewd", price: 30, stock: 2, createdAt: "", isPublish: true, imageIds: [])
            ]
        )
    ]
}
struct ShimmeringStoreCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder for store image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .cornerRadius(10)
                .shimmering() // Add shimmer effect
            
            // Placeholder for text details
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .cornerRadius(5)
                    .shimmering()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 15)
                    .cornerRadius(5)
                    .shimmering()
                
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 15)
                        .cornerRadius(5)
                        .shimmering()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 15)
                        .cornerRadius(5)
                        .shimmering()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}



struct AsyncImageView: View {
    let imageId: String
    @State private var image: UIImage?
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image).resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                ShimmeringStoreCardPlaceholder()
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        NetworkManager.shared.downloadImage(from: .downloadImage(imageid: imageId))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to load image: \(error)")
                }
            } receiveValue: { data in
                if let image = UIImage(data: data) {
                    self.image = image
                }
            }
            .store(in: &cancellables)
    }
}



