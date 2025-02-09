//
//  CartViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/9/25.
//
import SwiftUI
import Combine
class CartViewModel: ObservableObject {
    @Published var cartItemCount: Int = 0
    private var cancellables = Set<AnyCancellable>()

    func createCart(storeID: String, products: [CartProduct], completionHandler: @escaping (Int?) -> Void) {
        UserDetails.storeId = storeID
        let createCartRequest = CreateCartRequest(
            products: products,
            customer_id: UserDetails.userId ?? ""
        )
        
        NetworkManager.shared.performRequest(
            url: String.createCart(),
            method: .POST,
            payload: createCartRequest,
            responseType: CreateCartResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                
                if case .failure(let error) = completion {
                    debugPrint("Cart creation failed:", error)
                    completionHandler(nil)
                }
            },
            receiveValue: { [weak self] response in
                if response.products.count > 0 {
                    self?.cartItemCount = response.products.count
                    completionHandler(self?.cartItemCount ?? nil)
                }
            }
        )
        .store(in: &cancellables)
       
    }

}

struct CreateCartRequest: Codable, RequestBody {
    let products: [CartProduct]
    let customer_id: String
}

struct CartProduct: Codable {
    let productID: String
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case quantity
    }
}


struct CreateCartResponse: Codable {
    let message: String
    let total_amount: Double
    let tax_amount: Double
    let total_amount_with_tax: Double
//    let cart_id: String
    let products: [CartProductResponse]
}

struct CartProductResponse: Codable {
    let productID: String
    let quantity: Int
    let price: Double
    let productName: String

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case quantity
        case price
        case productName = "product_name"
    }
}

