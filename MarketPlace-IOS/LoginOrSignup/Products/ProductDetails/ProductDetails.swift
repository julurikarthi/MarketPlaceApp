//
//  ProductDetails.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//
import SwiftUI
import Combine
import Shimmer

struct ProductDetails: View {
    @State private var currentImageIndex = 0
    @State private var quantity = 1
    @StateObject var viewModel: ProductDetailsViewModel
    @State var showLoginView = false
    @State private var isPresentingFullScreenImage = false

    init(viewModel: ProductDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: ProductDetailsViewModel(product_id: viewModel.product_id))
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        CartNavigationView(title: "Details") {
            ScrollView {
                if viewModel.isLoading {
                    ShimmeringStoreCardPlaceholder()
                } else {
                    productDetailView()
                }
            }
            .onAppear {
                viewModel.getProductDetails(productID: viewModel.product_id)
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .accentColor(Color.themeRed)
            .tint(Color.themeRed)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.themeRed)
                    }
                }
            }
            .sheet(isPresented: $showLoginView) {
                LoginView()
            }
            .navigationBarBackButtonHidden()
        }
    }

    private func productDetailView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image Gallery
            TabView(selection: $currentImageIndex) {
                ForEach(viewModel.product?.imageids ?? [], id: \.self) { imageId in
                    AsyncImageView(imageId: imageId)
                        .cornerRadius(20)
                        .onTapGesture {
                            isPresentingFullScreenImage = true
                        }
                        .tag(viewModel.product?.imageids?.firstIndex(of: imageId) ?? 0)
                }
            }
            .frame(height: 300)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .overlay(
                ImageCounter(current: currentImageIndex + 1, total: viewModel.product?.imageids?.count ?? 0)
                    .padding(.bottom, 12)
                    .padding(.trailing, 12),
                alignment: .bottomTrailing
            )
            .padding(.horizontal)

            // Product Details
            VStack(alignment: .leading, spacing: 24) {
                // Product Name
                Text(viewModel.product?.product_name ?? "")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

                // Price and Stock
                HStack {
                    PriceTag(price: viewModel.product?.price ?? 0)
                    Spacer()
                    StockBadge(stock: viewModel.product?.stock ?? 0)
                }

                // Add to Cart Button
                if let product = viewModel.product {
                    CartButtonView(showLoginview: $showLoginView, viewModel: ProductCellItemViewModel(product: product, delegate: viewModel))
                }

                // Product Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Text(viewModel.product?.description ?? "")
                        .font(.body)
                        .foregroundColor(.subtitleGray)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            .padding()
        }
        .sheet(isPresented: $isPresentingFullScreenImage) {
            FullScreenImageView(imageIds: viewModel.product?.imageids ?? [], currentIndex: $currentImageIndex)
        }
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let imageIds: [String]
    @Binding var currentIndex: Int
    @State private var zoomScale: CGFloat = 1.0
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(imageIds.indices, id: \.self) { index in
                    ZoomableImageView(imageId: imageIds[index], zoomScale: $zoomScale)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .ignoresSafeArea()
            .overlay(
                Button(action: {
                    zoomScale = 1.0
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(.top, 40)
                .padding(.trailing, 20),
                alignment: .topTrailing
            )
        }
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let imageId: String
    @Binding var zoomScale: CGFloat

    var body: some View {
        AsyncImageView(imageId: imageId)
            .scaleEffect(zoomScale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoomScale = value
                    }
                    .onEnded { _ in
                        withAnimation {
                            zoomScale = 1.0
                        }
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation {
                    zoomScale = zoomScale > 1.0 ? 1.0 : 2.0
                }
            }
    }
}



// MARK: - Image Counter
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

// MARK: - Price Tag
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

// MARK: - Stock Badge
struct StockBadge: View {
    let stock: Int

    var body: some View {
        Text(stock > 0 ? "In Stock" : "Out of Stock")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(stock > 0 ? Color.green : Color.red)
            .cornerRadius(15)
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

