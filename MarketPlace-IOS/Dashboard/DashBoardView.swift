


import SwiftUI
import Shimmer

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
                              StoreCard(store: store)
                          }
                      }
                      .padding()
                  }
              }
              .navigationTitle("Stores")
          }
          .task {
              viewModel.getCurrentLocation()
              viewModel.getDashboardData()
          }
      }
}

struct StoreCard: View {
    let store: StoreData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Store Image
            AsyncImage(url: URL(string: "https://your-image-url.com/\(store.imageId ?? "")")) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 200)
            .cornerRadius(10)
            .clipped()
            
            // Store Details
            VStack(alignment: .leading, spacing: 8) {
                Text(store.storeName ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(store.storeType ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Pincode: \(store.pincode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("State: \(store.state)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Products Section
                if !store.products.isEmpty {
                    Text("Products")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.products) { product in
                                ProductCard(product: product)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct ProductCard: View {
    let product: ProductDashBoard
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content (image and details)
            VStack(alignment: .leading, spacing: 4) {
                // Product Image
                if let imageId = product.imageIds?.first {
                    AsyncImage(url: URL(string: "https://your-image-url.com/\(imageId)")) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                    .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                }
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName ?? "")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Stock: \(product.stock)")
                        .font(.caption2)
                        .foregroundColor(product.stock > 0 ? Color.blue : Color.red.opacity(0.8))
                }
            }
            
            AddToCartView()
                .offset(x: 0, y: -50)
        }
        .frame(width: 140) // Ensure consistent card size
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
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
