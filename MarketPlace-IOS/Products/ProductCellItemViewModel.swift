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
    @Published var product: Product
    var delegate: ProductListViewModelDelegate
    var selectedCategory: Category? = nil
    let reviewCount: Int = 20
    let rating: Float = 4
    var isAddedToCart = true

    init(product: Product, delegate: ProductListViewModelDelegate,
         selectedCategory: Category? = nil) {
        self.product = product
        self.productTitle = product.product_name
        self.productPrice = product.price
        self.description = product.description
        self.stock = "\(product.stock)"
        self.stockCount = product.stock
        imageIds = product.imageids ?? []
        self.delegate = delegate
        self.selectedCategory = selectedCategory
    }
    
    func addToCart(quantity: Int) {
           print("Added \(quantity) of \(productTitle) to cart")
            isAddedToCart = true
           // Implement your cart logic here
       }
    
    func downloadproductImages() {
        var imageURLs = [String]()
        
        // Generate URLs from image IDs
//        imageIds.forEach { str in
//            imageURLs.append(String.downloadImage(imageid: str))
//        }
        imageURLs.append(String.downloadImage(imageid: imageIds.first ?? ""))

        
        downloadImages(from: imageURLs)
            .receive(on: DispatchQueue.main)
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
                    DispatchQueue.main.async {
                        self.productImages = imageDataArray
                    }
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
    
    func editProduct() {
        if let selectedCategory = selectedCategory {
            let ediProduct = EditProduct(product_id: product.product_id, product_name: product.product_name, description: product.description, price: product.price, stock: product.stock,  imageids: product.imageids ?? [], isPublish: true, selectedPhotos: self.productImages, categoryID: selectedCategory)
            delegate.didtapOnEditButton(for: ediProduct)
        }
      
    }

    func deleteProduct() {
        delegate.didtapOnDeleteButton(for: product)
    }
    
    func didTapOnProduct() {
        delegate.didtapProduct(for: product)
    }

}


