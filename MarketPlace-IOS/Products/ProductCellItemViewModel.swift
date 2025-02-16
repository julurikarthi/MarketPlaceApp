//
//  ProductCellItemViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/28/25.
//
import SwiftUI
import Foundation
import Combine

class ProductCellItemViewModel: ObservableObject {
    var productTitle: String
    var productPrice: Double
    var description: String
    var stock: String
    @Published var productImages: UIImage?
    var addToCartAction: (() -> Void?)? = nil
    var stockCount: Int = 0
    var imageIds: [String]
    var cancellables = Set<AnyCancellable>()
    @Published var product: Product
    weak var delegate: ProductListViewModelDelegate? = nil
    var selectedCategory: Category? = nil
    let reviewCount: Int = 20
    let rating: Float = 4
    var isAddedToCart = true
    @Published var itemCount: Int = 0
    init(product: Product, delegate: ProductListViewModelDelegate? = nil,
         selectedCategory: Category? = nil) {
        self.product = product
        self.productTitle = product.product_name
        self.productPrice = product.price
        self.description = product.description ?? ""
        self.stock = "\(product.stock ?? 0)"
        self.stockCount = product.stock ?? 0
        imageIds = product.imageids ?? []
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        itemCount = product.quantity ?? 0        
    }
    
    func addToCart(quantity: Int) {
           print("Added \(quantity) of \(productTitle) to cart")
            isAddedToCart = true
           // Implement your cart logic here
       }
    
    func downloadProductImages(completion: @escaping (UIImage?) -> Void) {
        guard let firstImageID = imageIds.first, !firstImageID.isEmpty else {
            print("No valid image ID found")
            completion(nil)
            return
        }

        let imageURL = String.downloadImage(imageid: firstImageID)

        if let cachedImage = ImageDownloader.shared.getCachedImage(for: imageURL) {
            completion(cachedImage)
            return
        }

        DispatchQueue.global(qos: .background).async {
            NetworkManager.shared.downloadImage(from: imageURL)
                .tryMap { data -> UIImage in
                    guard let image = UIImage(data: data) else {
                        throw URLError(.cannotDecodeContentData)
                    }
                    
                    // Resize image to suitable dimensions (e.g., max width: 500px)
                    let resizedImage = image.resized(toWidth: 500)
                    
                    // Compress image for better memory performance
                    guard let compressedData = resizedImage.jpegData(compressionQuality: 0.8),
                          let finalImage = UIImage(data: compressedData) else {
                        throw URLError(.cannotDecodeContentData)
                    }
                    
                    // Cache resized image
                    ImageDownloader.shared.cacheImage(finalImage, for: imageURL)
                    return finalImage
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completionStatus in
                        if case .failure(let error) = completionStatus {
                            print("Image download failed: \(error.localizedDescription)")
                            completion(nil)
                        }
                    },
                    receiveValue: { downloadedImage in
                        print("Image downloaded and optimized")
                        completion(downloadedImage)
                    }
                )
                .store(in: &self.cancellables)
        }
    }


    private func downloadImages(from urls: [String]) -> AnyPublisher<[UIImage], Error> {
        print(urls)
        let publishers: [AnyPublisher<UIImage, Error>] = urls.compactMap { url in
            if let cachedImage = ImageDownloader.shared.getCachedImage(for: url) {
                return Just(cachedImage)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                // Download the image and cache it
                return NetworkManager.shared.downloadImage(from: url)
                    .tryMap { data in
                        guard let image = UIImage(data: data) else {
                            throw URLError(.cannotDecodeContentData)
                        }
                        ImageDownloader.shared.cacheImage(image, for: url)
                        return image
                    }
                    .eraseToAnyPublisher()
            }
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func editProduct() {
        if let selectedCategory = selectedCategory {
            let ediProduct = EditProduct(product_id: product.product_id, product_name: product.product_name, description: product.description ?? "", price: product.price, stock: product.stock ?? 0,  imageids: product.imageids ?? [], isPublish: true,
                                         categoryID: selectedCategory)
            delegate?.didtapOnEditButton(for: ediProduct)
        }
      
    }

    func deleteProduct() {
        delegate?.didtapOnDeleteButton(for: product)
    }
    
    func didTapOnProduct() {
        delegate?.didtapProduct(for: product)
    }

}



extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: width, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}
