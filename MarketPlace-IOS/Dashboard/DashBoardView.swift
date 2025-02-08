


import SwiftUI
import Shimmer
import Combine

struct DashboardView: View {
  
    @State private var stores: [Store] = []
    @StateObject private var viewModel = DashBoardViewViewModel()

    var body: some View {
          NavigationStack {
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
                              StoreCard(viewModel: .init(store: store))
                          }
                      }
                      .padding()
                  }
              }.toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                      Button(action: {
                          viewModel.movetoSelectLocation = true
                      }) {
                          Image("pin").resizable().frame(width: 20, height: 20)
                              .foregroundColor(Color.black)
                          Text(viewModel.address?.postalCode ?? viewModel.pincode ?? "").bold().foregroundColor(.black)
                          Image("arrow-down").resizable()
                              .frame(width: 10, height: 10)
                              .foregroundColor(Color.black)
                      }
                  }
                  ToolbarItem(placement: .navigationBarTrailing) {
                      // Add a button on the right side
                      Button(action: {
                          // Action to add a product
                      }) {
                          Image("shopping-cart").resizable().frame(width: 20, height: 20).padding(.trailing, 4)
                      }
                      .frame(height: 200)
                      .cornerRadius(10)
                      .clipped()
                  }
              }
              .navigationTitle("Stores")
          }.sheet(isPresented: $viewModel.movetoSelectLocation) {
              LocationSearchView(onAddressSelected: { address in
                  viewModel.address = address
              })
          }
          .task {
              await viewModel.getCurrentLocation()
              viewModel.getDashboardData()
          }
       
      }
}

struct StoreCard: View {
    @ObservedObject var viewModel: StoreCardViewModel
    @State private var showAllProducts = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Store Image
            VStack {
                AsyncImageView(imageId: viewModel.store.imageId ?? "")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
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
                                        ProductCard(viewModel: .init(product: product)).padding([.top, .bottom],5)
                                    }
                                }
                            }
                     
                            HStack {
                                Spacer()
                                Button("View All") {
                                    UserDetails.storeId = viewModel.store.storeId
                                    UserDetails.userType = "Customer"
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
                destination: ProductListView(isCustomer: true)
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(viewModel.store.storeName?.capitalized ?? "Store"),
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

                    
                    Text("$\(viewModel.product.price, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text("Stock: \(viewModel.product.stock)")
                        .font(.caption2)
                        .foregroundColor(viewModel.product.stock > 0 ? Color.gray : Color.red.opacity(0.8))
                }.padding(4)
            }
            
            AddToCartView()
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
        }
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}

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
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ShimmeringStoreCardPlaceholder()
                    .onAppear(perform: loadImage)
            }
        }
        .frame(width: 200, height: 200)
        .cornerRadius(15)
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


