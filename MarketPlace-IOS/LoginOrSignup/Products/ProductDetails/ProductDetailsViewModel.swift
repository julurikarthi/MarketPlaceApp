//
//  ProductDetailsViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/11/25.
//


import SwiftUI
import Foundation
import Combine
class ProductDetailsViewModel: ObservableObject {
    @Published var product: Product? = nil
    var product_id: String
    private var cancellables = Set<AnyCancellable>()
    @Published var isLoading: Bool = true
    init(product_id: String) {
        self.product_id = product_id
    }
    
    func getProductDetails(productID: String) {
        let request = GetProductDetailsRequest(
            userType: UserDetails.isAppOwners ? .storeOwner : .customer,
               product_id: productID
           )
        
        NetworkManager.shared.performRequest(
            url: String.getproductDetails(),
            method: .POST,
            payload: request,
            responseType: ProductResponse.self
        ).receive(on: DispatchQueue.main)
            .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                    print("Product details fetched successfully.")
                case .failure(let error):
                    self.isLoading = false
                    print("Failed to fetch product details: \(error.localizedDescription)")
                }
            },
            receiveValue: { response in
                DispatchQueue.main.async {
                    self.product = response.product
                    self.isLoading = false
                    self.objectWillChange.send()
                    print("isLoading: \(self.isLoading)")
                    print("Product received: \(self.product != nil)")
                }
            }
        ).store(in: &cancellables)
    }

}
struct GetProductDetailsRequest: Codable, RequestBody {
    let userType: String
    let product_id: String
}
struct ProductResponse: Codable {
    let product: Product
}
extension ProductDetailsViewModel: ProductListViewModelDelegate {
    func didtapOnEditButton(for product: EditProduct) {
            
    }
    
    func didtapOnDeleteButton(for product: Product) {
        
    }
    
    func didtapProduct(for product: Product) {
        
    }
    
}
