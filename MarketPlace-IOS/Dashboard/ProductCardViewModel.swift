//
//  ProductCardViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/31/25.
//

import SwiftUI
import Combine
class ProductCardViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    @Published var image: UIImage?
    var product: ProductDashBoard
    @Published var itemCount: Int = 0
    @Published var requestCount: Int = 0
    init(product: ProductDashBoard) {
        self.product = product
        itemCount = product.quantity
        if let imageid =  product.imageids.first  {
            downloadImage(imageId: imageid)
        }
    }
    func downloadImage(imageId: String) {
        NetworkManager.shared.downloadImage(from: .downloadImage(imageid: imageId))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to load image: \(error)")
                }
            } receiveValue: { data in
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
            .store(in: &cancellables)
    }
    
}
