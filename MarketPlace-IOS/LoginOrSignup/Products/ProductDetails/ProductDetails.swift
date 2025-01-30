//
//  ProductDetails.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//
import SwiftUI
import Combine

struct ProductDetails: View {
    @Binding var product: GetAllStoreProductsResponse.Product
    @StateObject private var imageLoader = ImageLoader()
    @State private var currentImageIndex = 0
    @State private var quantity = 1
    @State private var isAddingToCart = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Gallery
                    ImageGallery(imageLoader: imageLoader, imageIds: product.imageids, currentIndex: $currentImageIndex, colors: CustomColors())
                        .frame(height: 300)
                        .cornerRadius(20)
                        .overlay(
                            ImageCounter(current: currentImageIndex + 1, total: product.imageids.count)
                                .padding(.bottom, 12)
                                .padding(.trailing, 12),
                            alignment: .bottomTrailing
                        )
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Product Name
                        Text(product.productName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        // Price and Stock
                        HStack {
                            PriceTag(price: product.price)
                            Spacer()
                            StockBadge(stock: product.stock)
                        }
                        
                        // Quantity Selector
                        QuantitySelector(quantity: $quantity, maxStock: product.stock)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.subtitleGray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Add to Cart Button
                        AddToCartButton(
                            product: product,
                            quantity: quantity,
                            isAddingToCart: $isAddingToCart
                        )
                        
                        // Additional Details
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(title: "Product ID", value: product.productId)
                            DetailRow(title: "Store ID", value: product.storeId)
                            DetailRow(title: "Category", value: product.category_id)
                            DetailRow(title: "Created", value: formatDate(product.createdAt))
                            if let updated = product.updatedAt {
                                DetailRow(title: "Updated", value: formatDate(updated))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding()
                }
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                loadImages()
            }
        }
    }
    
    private func loadImages() {
        for imageId in product.imageids {
            imageLoader.loadImage(for: imageId)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy HH:mm"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Quantity Selector

struct QuantitySelector: View {
    @Binding var quantity: Int
    let maxStock: Int
    
    var body: some View {
        HStack {
            Text("Quantity")
                .foregroundColor(.subtitleGray)
            
            Spacer()
            
            HStack {
                Button(action: {
                    if quantity > 1 {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.themeRed)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Text("\(quantity)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    if quantity < maxStock {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.themeRed)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.vertical, 8)
    }
}

struct ImageCounter: View {
    let current: Int
    let total: Int
    
    var body: some View {
        Text("\(current)/\(total)")
            .font(.caption)
            .padding(6)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(15)
    }
}


// MARK: - Add to Cart Button

struct AddToCartButton: View {
    let product: GetAllStoreProductsResponse.Product
    let quantity: Int
    @Binding var isAddingToCart: Bool
    
    var body: some View {
        Button(action: {
            addToCart()
        }) {
            HStack {
                if isAddingToCart {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.themeRed)
            .foregroundColor(.white)
            .cornerRadius(15)
            .font(.headline)
        }
        .disabled(isAddingToCart)
    }
    
    private func addToCart() {
        isAddingToCart = true
        
        // Simulate cart addition (replace with your actual cart logic here!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Added \(quantity) of \(product.productName) to cart.")
            isAddingToCart = false
            
            // Optional success alert or toast can be added here.
        }
    }
}

// MARK - Supporting Views

struct PriceTag: View {
    let price: Double
    
    var body: some View {
        Text("$\(price, specifier: "%.2f")")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green)
            .cornerRadius(20)
    }
}

struct StockBadge: View {
    let stock: Int
    
    var body: some View {
        Text("In Stock \(stock)")
            .font(.subheadline)
            .foregroundColor(stock > 0 ? Color.subtitleGray : Color.red.opacity(0.8))
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).fontWeight(.medium).foregroundColor(.green)
            Spacer()
            Text(value).foregroundColor(.subtitleGray).lineLimit(1).truncationMode(.tail)
        }
    }
}

//struct ProductDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProductDetails(product: GetAllStoreProductsResponse.Product(
//                productId: "679649017a1088e29d201351",
//                storeId: "67940eb1e6556665f861cdb4",
//                productName: "Enchanted Garden Bouquet",
//                price: 39.99,
//                stock: 25,
//                description: "Immerse yourself in the beauty of nature with our Enchanted Garden Bouquet. This stunning arrangement features a harmonious blend of pastel roses, delicate lilies, and lush greenery. Perfect for adding a touch of magic to any space or occasion.",
//                category_id: "Spring Collection",
//                createdAt: "2025-01-26T14:38:57.874",
//                updatedAt: nil,
//                imageids: [
//                    "enchanted-garden-1.jpg",
//                    "enchanted-garden-2.jpg",
//                    "enchanted-garden-3.jpg"
//                ]
//            ))
//        }
//    }
//}
struct ImageGallery: View {
    @ObservedObject var imageLoader: ImageLoader
    let imageIds: [String]
    @Binding var currentIndex: Int
    let colors: CustomColors
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<imageIds.count, id: \.self) { index in
                if let image = imageLoader.images[imageIds[index]] {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(colors.backgroundSecondary)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}
struct CustomColors {
    let backgroundPrimary = Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.7450980544, alpha: 1))
    let backgroundSecondary = Color(#colorLiteral(red: 0.9568627477, green: 0.8941176534, blue: 0.8666666746, alpha: 1))
    let accent = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
    let textPrimary = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    let textSecondary = Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
}
class ImageLoader: ObservableObject {
    @Published var images: [String: UIImage] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    func loadImage(for imageId: String) {
        guard images[imageId] == nil else { return }
        
        NetworkManager.shared.downloadImage(from: .downloadImage(imageid: imageId))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to load image: \(error)")
                }
            } receiveValue: { data in
                if let image = UIImage(data: data) {
                    self.images[imageId] = image
                }
            }
            .store(in: &cancellables)
    }
}

