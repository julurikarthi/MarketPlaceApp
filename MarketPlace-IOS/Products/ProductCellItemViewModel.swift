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
    @Published var productImages: [UIImage] = []
    var addToCartAction: (() -> Void?)? = nil
    var stockCount: Int = 0
    var imageIds: [String]
    var cancellables = Set<AnyCancellable>()
    @Published var product: GetAllStoreProductsResponse.Product
    init(product: GetAllStoreProductsResponse.Product) {
        self.product = product
        self.productTitle = product.productName
        self.productPrice = product.price
        self.description = product.description
        self.stock = "\(product.stock)"
        self.stockCount = product.stock
        imageIds = product.imageids
    }
    
   
    
    func downloadproductImages() async {
        var imageURLs = [String]()
        
        // Generate URLs from image IDs
        imageIds.forEach { str in
            imageURLs.append(String.downloadImage(imageid: str))
        }
        
        // Start downloading images
        downloadImages(from: imageURLs)
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("All images downloaded successfully.")
                    case .failure(let error):
                        print("Failed to download images: \(error.localizedDescription)")
                    }
                },
                receiveValue: { imageDataArray in
                    self.productImages = imageDataArray
                }
            )
            .store(in: &cancellables)
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


}


